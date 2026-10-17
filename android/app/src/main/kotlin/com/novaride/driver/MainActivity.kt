package com.novaride.driver

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        CrashRecorder.install(applicationContext)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "novaride/diagnostics")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumeLastCrash" -> result.success(CrashRecorder.consume(applicationContext))
                    else -> result.notImplemented()
                }
            }
    }
}
