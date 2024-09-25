// In Settings V0 we used the SharedPreferences API to set the keys and
// values, but each of these API functions (of the flutter/SharedPreferences
// version we started with) made an atomic update to the settings and thus we
// couldn't update multiple values and then commit then all at once
// atomically.  Since Settings V1 we store everything in just one
// SharedPreferences key, the `atomicSharedPrefsSettingsKey`, and save/commit
// the whole thing atomically at once.
const String atomicSharedPrefsSettingsKey = "settings";
