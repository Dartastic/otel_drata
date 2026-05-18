// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_drata/otel_drata.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_drata-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('monitors.run records framework + asset + counts', () async {
    await tracedDrata<String>(
      operation: 'monitors.run',
      invoke: () async => const DrataCallResult(
        value: 'ok',
        result: DrataResult(
          workspaceId: 'ws_1',
          frameworkSlug: 'soc2_type2',
          controlId: 'access-control',
          requirementId: 'CC6.1',
          monitorId: 'mfa-enabled',
          monitorStatus: 'passing',
          assetKind: 'personnel',
          severity: 'high',
          failingAssets: 0,
          passingAssets: 87,
          integrationKey: 'okta',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('drata monitors.run')!);
    expect(a['drata.framework.slug'], 'soc2_type2');
    expect(a['drata.requirement.id'], 'CC6.1');
    expect(a['drata.monitor.status'], 'passing');
    expect(a['drata.passing.assets'], 87);
    expect(a['drata.integration.key'], 'okta');
  });

  test('failing monitor sets span error', () async {
    await tracedDrata<String>(
      operation: 'monitors.get',
      invoke: () async => const DrataCallResult(
        value: 'ok',
        result: DrataResult(
          monitorId: 'disk-encryption',
          monitorStatus: 'failing',
          ownerEmail: 'sec@example.com',
          failingAssets: 4,
        ),
      ),
    );
    expect(
      spans.findSpanByName('drata monitors.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('snoozed monitor does not error', () async {
    await tracedDrata<String>(
      operation: 'monitors.snooze',
      invoke: () async => const DrataCallResult(
        value: 'ok',
        result: DrataResult(
          monitorId: 'temp-bypass',
          monitorStatus: 'snoozed',
          snoozeUntilSec: 1735776000,
        ),
      ),
    );
    final s = spans.findSpanByName('drata monitors.snooze')!;
    expect(s.status, isNot(SpanStatusCode.Error));
    expect(attrsOf(s)['drata.snooze.until_sec'], 1735776000);
  });

  test('suppression skips spans', () async {
    await runWithoutDrataInstrumentationAsync(() async {
      await tracedDrata<String>(
        operation: 'assets.list',
        invoke: () async => const DrataCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('drata '), isEmpty);
  });
}
