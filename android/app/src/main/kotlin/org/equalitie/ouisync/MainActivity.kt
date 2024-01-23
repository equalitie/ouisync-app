package org.equalitie.ouisync

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

import android.os.Environment 
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
  private val CHANNEL = "org.equalitie.ouisync_app/native"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
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
  
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState);
  }

  private fun startGetDownloadPath(): String? {
    val downloadDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
    return downloadDirectory.toString()
  } 
}
