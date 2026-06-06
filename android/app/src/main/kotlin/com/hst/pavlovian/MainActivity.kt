package com.hst.pavlovian

import android.app.Activity
import android.content.Intent
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.hst.pavlovian/ringtone"
        private const val PICK_REQUEST_CODE = 4711
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickRingtone" -> handlePickRingtone(call, result)
                    "ringtoneTitle" -> handleRingtoneTitle(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    // Opens Android's native ringtone picker for notification sounds.
    // Returns the picked URI (string) or null if the user cancelled.
    private fun handlePickRingtone(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result
    ) {
        pendingResult = result
        val currentUriArg = call.argument<String?>("currentUri")
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_NOTIFICATION)
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Pick alert sound")
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            if (currentUriArg != null) {
                putExtra(
                    RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                    Uri.parse(currentUriArg)
                )
            }
        }
        startActivityForResult(intent, PICK_REQUEST_CODE)
    }

    // Look up the user-facing title for a given URI (e.g. "Spaceline").
    private fun handleRingtoneTitle(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result
    ) {
        val uriString = call.argument<String?>("uri")
        if (uriString == null) {
            result.success(null)
            return
        }
        try {
            val rt: Ringtone? = RingtoneManager.getRingtone(this, Uri.parse(uriString))
            result.success(rt?.getTitle(this))
        } catch (e: Throwable) {
            result.success(null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_REQUEST_CODE) return
        val cb = pendingResult
        pendingResult = null
        if (resultCode == Activity.RESULT_OK) {
            val uri: Uri? = data?.getParcelableExtra(
                RingtoneManager.EXTRA_RINGTONE_PICKED_URI
            )
            cb?.success(uri?.toString())
        } else {
            cb?.success(null)
        }
    }
}
