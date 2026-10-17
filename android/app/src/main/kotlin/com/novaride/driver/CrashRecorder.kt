package com.novaride.driver

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.content.Context
import android.os.Build
import android.util.Log
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Keeps the reason the process last died so the next launch can show/report it.
 *
 * Crashlytics only sees Java/Dart exceptions it manages to upload; a native
 * signal or a system kill leaves nothing behind. Two sources are recorded:
 *  - uncaught Java/Kotlin exceptions (written synchronously before the process dies)
 *  - Android's own exit history (ApplicationExitInfo, API 30+): CRASH, CRASH_NATIVE, ANR, ...
 */
object CrashRecorder {
    private const val FILE = "last_crash.txt"
    private const val PREFS = "crash_recorder"
    private const val KEY_LAST_EXIT_TS = "last_exit_ts"
    private var installed = false

    fun install(context: Context) {
        if (installed) return
        installed = true
        val app = context.applicationContext
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, error ->
            try {
                File(app.filesDir, FILE).writeText(
                    "${stamp(System.currentTimeMillis())} uncaught exception on thread '${thread.name}'\n" +
                        Log.getStackTraceString(error).take(6000),
                )
            } catch (_: Throwable) {
            }
            previous?.uncaughtException(thread, error)
        }
    }

    /** Everything new since the last call, or an empty string. */
    fun consume(context: Context): String {
        val out = StringBuilder()

        val file = File(context.filesDir, FILE)
        if (file.exists()) {
            try {
                out.append(file.readText()).append("\n\n")
            } catch (_: Throwable) {
            }
            file.delete()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                val lastSeen = prefs.getLong(KEY_LAST_EXIT_TS, 0L)
                val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                val exits = am.getHistoricalProcessExitReasons(context.packageName, 0, 8)
                var newest = lastSeen
                for (e in exits) {
                    if (e.timestamp <= lastSeen) continue
                    newest = maxOf(newest, e.timestamp)
                    val reason = reasonName(e.reason) ?: continue
                    out.append("${stamp(e.timestamp)} exit=$reason status=${e.status} ")
                        .append("importance=${e.importance} pss=${e.pss}KB rss=${e.rss}KB ")
                        .append("desc=${e.description}\n")
                }
                prefs.edit().putLong(KEY_LAST_EXIT_TS, newest).apply()
            } catch (_: Throwable) {
            }
        }

        if (out.isNotEmpty()) {
            out.append("device=${Build.MANUFACTURER} ${Build.MODEL} android=${Build.VERSION.RELEASE} sdk=${Build.VERSION.SDK_INT}\n")
        }
        return out.toString().trim()
    }

    /** Only the exits that mean "something went wrong"; null for normal ones. */
    private fun reasonName(reason: Int): String? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        when (reason) {
            ApplicationExitInfo.REASON_CRASH -> "CRASH"
            ApplicationExitInfo.REASON_CRASH_NATIVE -> "CRASH_NATIVE"
            ApplicationExitInfo.REASON_ANR -> "ANR"
            ApplicationExitInfo.REASON_LOW_MEMORY -> "LOW_MEMORY"
            ApplicationExitInfo.REASON_INITIALIZATION_FAILURE -> "INITIALIZATION_FAILURE"
            ApplicationExitInfo.REASON_EXCESSIVE_RESOURCE_USAGE -> "EXCESSIVE_RESOURCE_USAGE"
            ApplicationExitInfo.REASON_SIGNALED -> "SIGNALED"
            ApplicationExitInfo.REASON_DEPENDENCY_DIED -> "DEPENDENCY_DIED"
            ApplicationExitInfo.REASON_OTHER -> "OTHER"
            else -> null
        }
    } else null

    private fun stamp(ms: Long): String =
        SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US).format(Date(ms))
}
