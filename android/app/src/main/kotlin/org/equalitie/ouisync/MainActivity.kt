package org.equalitie.ouisync

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Environment
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  companion object {
    private val CHANNEL = "org.equalitie.ouisync/native"
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result -> 
      when(call.method) {
        "getDownloadPath" -> {
          val downloadPath = startGetDownloadPath()
          result.success(downloadPath)
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }

  private fun startGetDownloadPath(): String? {
    val downloadDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
    return downloadDirectory.toString()
  } 
}
