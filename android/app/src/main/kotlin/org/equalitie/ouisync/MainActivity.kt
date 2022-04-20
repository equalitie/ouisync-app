package org.equalitie.ouisync

import android.os.Bundle
import android.net.Uri
import android.util.Log;
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

class MainActivity: FlutterActivity() {
  private val TAG = "flutter-ouisync-java"

  // For sending intent's data to flutter
  lateinit var channel : MethodChannel

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState);

    // TODO: On the flutter side, the channel is initialized only after this
    // function is finished (and this function is called only after the
    // configureFlutterEngine function). Therefore this intent is never
    // actually delivered to flutter. A workaround that comes to my mind is to
    // temporarily store the intents and wait for a message from flutter that
    // the channel is ready. At which point we would flush the intents to the
    // channel.
    if (intent != null) {
      handleIntent(intent);
    }
  }

  override fun onNewIntent(intent: Intent) {
    handleIntent(intent);
  }

  fun handleIntent(intent: Intent) {
    if (intent.action != Intent.ACTION_VIEW) {
      return;
    }
    if (channel == null) {
      Log.w(TAG, "Received an intent, but flutter engine has not yet been attached");
      return;
    }

    channel.invokeMethod("openShareToken", intent.data.toString(), object: MethodChannel.Result {
      // We're not interested in the results here.
      // TODO: Maybe implement the `notImplemented` method to warn/assert if
      // there is no one that receives this.
      override fun success(a: Any?) {}
      override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {}
      override fun notImplemented() {}
    })

  }

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ouisync_native_channel")
  }
}
