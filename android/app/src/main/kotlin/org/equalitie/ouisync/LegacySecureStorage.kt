package org.equalitie.ouisync

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import java.security.KeyStore

/**
 * Access to values stored by `flutter_secure_storage` 10.0.0-beta.4, used by Ouisync 0.9.4 and
 * older. On Android that version stored values using Jetpack's `EncryptedSharedPreferences`, which
 * newer versions of the plugin can't read (they only migrate it in 10.0.0 - 10.3.x, which we
 * skipped).
 *
 * The legacy data lives in the same `SharedPreferences` file as the data of the current plugin
 * version, so this must never clear the whole file.
 */
class LegacySecureStorage(private val context: Context) {
    companion object {
        // Values used by `flutter_secure_storage` 10.0.0-beta.4.
        private const val PREFS_NAME = "FlutterSecureStorage"
        private const val KEY_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIHNlY3VyZSBzdG9yYWdlCg_"

        // Entries where `EncryptedSharedPreferences` keeps its own (encrypted) keys.
        private const val KEY_KEYSET = "__androidx_security_crypto_encrypted_prefs_key_keyset__"
        private const val VALUE_KEYSET = "__androidx_security_crypto_encrypted_prefs_value_keyset__"

        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
    }

    /** Returns the legacy value stored under `key`, or `null` if there is none. */
    fun read(key: String): String? {
        val prefs = open() ?: return null
        return prefs.getString(KEY_PREFIX + key, null)
    }

    /**
     * Deletes the legacy value stored under `key`. When no legacy values remain, also deletes the
     * keys that protected them.
     */
    fun delete(key: String) {
        val prefs = open() ?: return
        prefs.edit().remove(KEY_PREFIX + key).commit()

        if (!hasLegacyEntries()) {
            plainPrefs().edit().remove(KEY_KEYSET).remove(VALUE_KEYSET).commit()

            val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE)
            keyStore.load(null)
            keyStore.deleteEntry(MasterKey.DEFAULT_MASTER_KEY_ALIAS)
        }
    }

    // Opening `EncryptedSharedPreferences` creates its keys if they don't exist yet, so only open it
    // when there is legacy data. Otherwise every fresh install would get an unused legacy store.
    private fun open(): SharedPreferences? {
        if (!hasLegacyStore()) {
            return null
        }

        val masterKey =
            MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()

        return EncryptedSharedPreferences.create(
            context,
            PREFS_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
        )
    }

    private fun hasLegacyStore(): Boolean {
        val prefs = plainPrefs()
        if (!prefs.contains(KEY_KEYSET) || !prefs.contains(VALUE_KEYSET)) {
            return false
        }

        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE)
        keyStore.load(null)
        return keyStore.containsAlias(MasterKey.DEFAULT_MASTER_KEY_ALIAS)
    }

    // Legacy entries have encrypted names. Everything else in the file is either one of the keysets
    // or an entry of the current plugin version, whose names start with `KEY_PREFIX`.
    private fun hasLegacyEntries(): Boolean =
        plainPrefs().all.keys.any {
            it != KEY_KEYSET && it != VALUE_KEYSET && !it.startsWith(KEY_PREFIX)
        }

    private fun plainPrefs(): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
