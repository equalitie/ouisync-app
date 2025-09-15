package org.equalitie.ouisync

import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.provider.DocumentsContract
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private val CHANNEL = "org.equalitie.ouisync/native"
        private val TAG = "ouisync"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler handler@{ call, result ->
                when (call.method) {
                    "getDownloadPath" -> {
                        val downloadPath = getDownloadPath()
                        result.success(downloadPath)
                    }
                    "getDocumentUri" -> {
                        val args = call.arguments as List<Any>
                        val path = args[0] as String
                        result.success(getDocumentUri(path).toString())
                    }
                    "log" -> {
                        val args = call.arguments as List<Any>
                        log(args[0] as Int, args[1] as String)
                        result.success(null)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun getDocumentUri(path: String): Uri =
        DocumentsContract.buildDocumentUri("$packageName.provider", path.replace('/', ':'))

    private fun getDownloadPath(): String? {
        val downloadDirectory =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        return downloadDirectory.toString()
    }

    private fun log(
        level: Int,
        message: String,
    ) {
        val priority =
            when (level) {
                1 -> Log.ERROR
                2 -> Log.WARN
                3 -> Log.INFO
                4 -> Log.DEBUG
                5 -> Log.VERBOSE
                else -> Log.VERBOSE
            }

        Log.println(priority, TAG, message)
    }
}
