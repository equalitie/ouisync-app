package org.equalitie.ouisync

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.HandlerThread
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.DocumentsContract
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private val CHANNEL = "org.equalitie.ouisync/native"
        private val TAG = "ouisync"
    }

    private var storageNotifier: StorageNotifier? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
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
                "getStorageVolume" -> {
                    val args = call.arguments as List<Any>
                    val path = args[0] as String
                    result.success(getStorageVolume(path)?.toMap())
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

        storageNotifier = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            CallbackStorageNotifier(methodChannel)
        } else {
            ReceiverStorageNotifier(methodChannel)
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        storageNotifier?.unregister()
        storageNotifier = null

        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun getDocumentUri(path: String): Uri = DocumentsContract.buildDocumentUri("$packageName.provider", path)

    private fun getDownloadPath(): String? {
        val downloadDirectory =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        return downloadDirectory.toString()
    }

    private fun getStorageVolume(path: String): StorageVolume? = storageManager.getStorageVolume(File(path))

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

    private fun StorageVolume.toMap(): Map<String, Any?> =
        mapOf(
            "isPrimary" to isPrimary() as Any,
            "isRemovable" to isRemovable() as Any,
            "isMounted" to (state == Environment.MEDIA_MOUNTED) as Any,
            "description" to getDescription(this@MainActivity) as Any,
            "mountPoint" to
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    getDirectory()?.getPath() as Any?
                } else {
                    null
                },
        )

    private val storageManager: StorageManager
        get() = getSystemService(STORAGE_SERVICE) as StorageManager

    private fun onStorageVolumeStateChange(methodChannel: MethodChannel) {
        // Not 100% sure about this, but it seems that if a removable storage is being
        // ejected and there are some repos (or any open files) on it, we need to close
        // them before this callback returns, otherwise the os kills the app
        // (possibly after a short delay).
        val latch = CountDownLatch(1)
        val result =
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    latch.countDown()
                }

                override fun error(
                    errorCode: String,
                    errorMessage: String?,
                    errorDetails: Any?,
                ) {
                    latch.countDown()
                }

                override fun notImplemented() {
                    latch.countDown()
                }
            }

        runOnUiThread { methodChannel.invokeMethod("storageVolumeChanged", null, result) }

        latch.await()
    }

    private sealed interface StorageNotifier {
        abstract fun unregister();
    }

    // Storage notifier backed by BroadcastReceiver. Works on any Android version supported by Ouisync.
    private inner class ReceiverStorageNotifier(methodChannel: MethodChannel) : StorageNotifier {
        private val handler = Handler(HandlerThread("storage volume receiver thread").apply { start() }.looper)
        private lateinit var receiver: BroadcastReceiver

        init {
            receiver =
                object : BroadcastReceiver() {
                    override fun onReceive(
                        context: Context,
                        intent: Intent,
                    ) {
                        Log.v(
                            TAG,
                            "storage volume state changed: action=${intent.action}, data=${intent.data}",
                        )

                        onStorageVolumeStateChange(methodChannel)
                    }
                }

            val filter =
                IntentFilter().apply {
                    addAction(Intent.ACTION_MEDIA_BAD_REMOVAL)
                    addAction(Intent.ACTION_MEDIA_CHECKING)
                    addAction(Intent.ACTION_MEDIA_EJECT)
                    addAction(Intent.ACTION_MEDIA_MOUNTED)
                    addAction(Intent.ACTION_MEDIA_NOFS)
                    addAction(Intent.ACTION_MEDIA_REMOVED)
                    addAction(Intent.ACTION_MEDIA_SHARED)
                    addAction(Intent.ACTION_MEDIA_UNMOUNTABLE)
                    addAction(Intent.ACTION_MEDIA_UNMOUNTED)

                    addDataScheme("file")
                }

            registerReceiver(receiver, filter, null, handler)
        }

        override fun unregister() {
            unregisterReceiver(receiver)
        }
    }

    // Storage notifier backed by StorageManager.StorageVolumeCallback. Works on Android API >= 30.
    private inner class CallbackStorageNotifier(methodChannel: MethodChannel) : StorageNotifier {
        private val executor = Executors.newSingleThreadExecutor()
        private lateinit var callback: StorageManager.StorageVolumeCallback

        init {
            callback = object : StorageManager.StorageVolumeCallback() {
                override fun onStateChanged(volume: StorageVolume) {
                    Log.v(
                        TAG,
                        "storage volume state changed: description=${volume.getDescription(this@MainActivity)}, state=${volume.state}",
                    )

                    onStorageVolumeStateChange(methodChannel)
                }
            }

            storageManager.registerStorageVolumeCallback(executor, callback)
        }

        override fun unregister() {
            storageManager.unregisterStorageVolumeCallback(callback)
        }
    }
}
