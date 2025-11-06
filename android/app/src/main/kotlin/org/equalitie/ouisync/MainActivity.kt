package org.equalitie.ouisync

import android.net.Uri
import android.os.Build
import android.os.Environment
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

    private val storageVolumeExecutor = Executors.newSingleThreadExecutor()
    private var storageVolumeCallback: StorageManager.StorageVolumeCallback? = null

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

        storageManager.let { storageManager ->
            storageVolumeCallback?.let { storageManager.unregisterStorageVolumeCallback(it) }

            storageVolumeCallback =
                object : StorageManager.StorageVolumeCallback() {
                    override fun onStateChanged(volume: StorageVolume) {
                        Log.v(
                            TAG,
                            "storage volume state changed: ${volume.getDescription(this@MainActivity)}, state: ${volume.state}",
                        )

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
                }.also { storageManager.registerStorageVolumeCallback(storageVolumeExecutor, it) }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        storageVolumeCallback?.let { storageManager.unregisterStorageVolumeCallback(it) }
        storageVolumeCallback = null

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
}
