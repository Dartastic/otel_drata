// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_drata/otel_drata.dart';

/// Traces Drata calls with OpenTelemetry.
///
/// `otel_drata` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Drata call in
/// [tracedDrata]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'drata-example');

  // Wraps a Drata API call in a CLIENT span.
  final drataId = await tracedDrata<String>(
    operation: 'monitors.run',
    invoke: () async {
      // Make the Drata call here, then report what it returned.
      const id = 'drata_8f3a2c';
      return const DrataCallResult(
          value: id,
          result: DrataResult(
              workspaceId: 'workspace_8f3a2c',
              frameworkSlug: 'soc2_type1',
              controlId: 'control_8f3a2c',
              requirementId: 'CC6.1',
              monitorId: 'monitor_8f3a2c',
              monitorStatus: 'passing',
              assetKind: 'personnel',
              assetId: 'asset_8f3a2c',
              ownerEmail: 'ada@example.com',
              severity: 'low',
              failingAssets: 1,
              passingAssets: 1,
              snoozeUntilSec: 1,
              evidenceId: 'evidence_8f3a2c',
              integrationKey: 'aws',
              statusCode: 200));
    },
  );
  OTelLog.info('tracedDrata monitors.run returned $drataId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutDrataInstrumentationAsync.
  await runWithoutDrataInstrumentationAsync(
    () => tracedDrata<String>(
      operation: 'monitors.run',
      invoke: () async {
        const id = 'drata_8f3a2c';
        return const DrataCallResult(
            value: id,
            result: DrataResult(
                workspaceId: 'workspace_8f3a2c',
                frameworkSlug: 'soc2_type1',
                controlId: 'control_8f3a2c',
                requirementId: 'CC6.1',
                monitorId: 'monitor_8f3a2c',
                monitorStatus: 'passing',
                assetKind: 'personnel',
                assetId: 'asset_8f3a2c',
                ownerEmail: 'ada@example.com',
                severity: 'low',
                failingAssets: 1,
                passingAssets: 1,
                snoozeUntilSec: 1,
                evidenceId: 'evidence_8f3a2c',
                integrationKey: 'aws',
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
