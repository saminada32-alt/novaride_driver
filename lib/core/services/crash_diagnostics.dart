import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'crash_reporting.dart';

/// Surfaces why the app's process died last time (Android only).
///
/// The native side (CrashRecorder.kt) keeps uncaught Java exceptions and
/// Android's exit history. On the next launch the report is sent to
/// Crashlytics as a non-fatal and shown once so it can be copied to support.
class CrashDiagnostics {
  CrashDiagnostics._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static const _channel = MethodChannel('novaride/diagnostics');

  static Future<void> checkLastRun() async {
    if (!Platform.isAndroid) return;
    try {
      final report = await _channel.invokeMethod<String>('consumeLastCrash');
      if (report == null || report.trim().isEmpty) return;

      await CrashReporting.log(report);
      await CrashReporting.recordError(
        Exception('Previous run ended abnormally: $report'),
        StackTrace.current,
      );
      await _show(report);
    } catch (e) {
      debugPrint('Crash diagnostics unavailable: $e');
    }
  }

  static Future<void> _show(String report) async {
    // The first route may not be mounted yet.
    for (var i = 0; i < 20; i++) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        await showDialog<void>(
          context: ctx,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('تقرير آخر إغلاق غير متوقع'),
            content: SingleChildScrollView(
              child: SelectableText(
                report,
                style: const TextStyle(fontSize: 11),
                textDirection: TextDirection.ltr,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: report)),
                child: const Text('نسخ'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }
}
