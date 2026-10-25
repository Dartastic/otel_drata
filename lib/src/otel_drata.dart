// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_drata_suppression.dart';

const _tracerName = 'dartastic_otel_libs_drata';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class DrataResult {
  /// Creates a result.
  const DrataResult({
    this.workspaceId,
    this.frameworkSlug,
    this.controlId,
    this.requirementId,
    this.monitorId,
    this.monitorStatus,
    this.assetKind,
    this.assetId,
    this.ownerEmail,
    this.severity,
    this.failingAssets,
    this.passingAssets,
    this.snoozeUntilSec,
    this.evidenceId,
    this.integrationKey,
    this.statusCode,
  });

  /// Drata workspace (tenant).
  final String? workspaceId;

  /// `soc2_type1` / `soc2_type2` / `iso_27001` / `hipaa` / `pci_dss` /
  /// `gdpr` / `ccpa` / `nist_800_53` / `nist_800_171` /
  /// `essential_eight` / `cyber_essentials` / `cmmc`.
  final String? frameworkSlug;

  final String? controlId;

  /// Framework-specific requirement (e.g., `CC6.1`).
  final String? requirementId;

  /// Drata's continuous-monitor unit (one observable check).
  final String? monitorId;

  /// `passing` / `failing` / `snoozed` / `disabled` / `not_applicable`.
  final String? monitorStatus;

  /// `personnel` / `device` / `production_account` / `repository` /
  /// `vendor` / `bucket` / `database` / `dns_record` / `cloud_account`.
  final String? assetKind;

  final String? assetId;

  /// Owner whose remediation queue this lands in.
  final String? ownerEmail;

  /// `low` / `medium` / `high` / `critical`.
  final String? severity;

  final int? failingAssets;
  final int? passingAssets;

  /// If non-null, monitor failures are suppressed until this unix sec.
  final int? snoozeUntilSec;

  final String? evidenceId;

  /// `aws` / `gcp` / `azure` / `okta` / `google_workspace` / `github`
  /// / `jamf` / `kandji` — the source integration.
  final String? integrationKey;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class DrataCallResult<T> {
  /// Creates a call result.
  const DrataCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final DrataResult? result;
}

/// Wraps a Drata API call in a CLIENT span. [operation] is one of
/// `controls.list`, `controls.get`, `monitors.list`,
/// `monitors.get`, `monitors.run`, `monitors.snooze`,
/// `evidence.upload`, `assets.list`, `personnel.list`,
/// `integrations.connect`, `risk_register.list`.
Future<T> tracedDrata<T>({
  required String operation,
  required Future<DrataCallResult<T>> Function() invoke,
}) async {
  if (drataInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'drata',
    'rpc.method': operation,
    'drata.operation': operation,
  };

  final span = _tracer().startSpan(
    'drata $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.workspaceId != null) {
        extras.add(OTelAPI.attributeString(
          'drata.workspace.id',
          r.result!.workspaceId!,
        ));
      }
      if (r.result!.frameworkSlug != null) {
        extras.add(OTelAPI.attributeString(
          'drata.framework.slug',
          r.result!.frameworkSlug!,
        ));
      }
      if (r.result!.controlId != null) {
        extras.add(OTelAPI.attributeString(
          'drata.control.id',
          r.result!.controlId!,
        ));
      }
      if (r.result!.requirementId != null) {
        extras.add(OTelAPI.attributeString(
          'drata.requirement.id',
          r.result!.requirementId!,
        ));
      }
      if (r.result!.monitorId != null) {
        extras.add(OTelAPI.attributeString(
          'drata.monitor.id',
          r.result!.monitorId!,
        ));
      }
      if (r.result!.monitorStatus != null) {
        extras.add(OTelAPI.attributeString(
          'drata.monitor.status',
          r.result!.monitorStatus!,
        ));
        if (r.result!.monitorStatus == 'failing') {
          span.setStatus(SpanStatusCode.Error, 'Drata monitor failing');
        }
      }
      if (r.result!.assetKind != null) {
        extras.add(OTelAPI.attributeString(
          'drata.asset.kind',
          r.result!.assetKind!,
        ));
      }
      if (r.result!.assetId != null) {
        extras.add(OTelAPI.attributeString(
          'drata.asset.id',
          r.result!.assetId!,
        ));
      }
      if (r.result!.ownerEmail != null) {
        extras.add(OTelAPI.attributeString(
          'drata.owner.email',
          r.result!.ownerEmail!,
        ));
      }
      if (r.result!.severity != null) {
        extras.add(OTelAPI.attributeString(
          'drata.severity',
          r.result!.severity!,
        ));
      }
      if (r.result!.failingAssets != null) {
        extras.add(OTelAPI.attributeInt(
          'drata.failing.assets',
          r.result!.failingAssets!,
        ));
      }
      if (r.result!.passingAssets != null) {
        extras.add(OTelAPI.attributeInt(
          'drata.passing.assets',
          r.result!.passingAssets!,
        ));
      }
      if (r.result!.snoozeUntilSec != null) {
        extras.add(OTelAPI.attributeInt(
          'drata.snooze.until_sec',
          r.result!.snoozeUntilSec!,
        ));
      }
      if (r.result!.evidenceId != null) {
        extras.add(OTelAPI.attributeString(
          'drata.evidence.id',
          r.result!.evidenceId!,
        ));
      }
      if (r.result!.integrationKey != null) {
        extras.add(OTelAPI.attributeString(
          'drata.integration.key',
          r.result!.integrationKey!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Drata HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
