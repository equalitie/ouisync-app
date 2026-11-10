# Creating a release

Bump the app version in `pubspec.yaml`.

Then run the following from the project root:

```bash
# Update dart dependencies
dart pub get
```

Prepare secrets (see the next section) and run

```bash
# Build Linux and Android packages
dart run util/release.dart --android-key-properties=$KEY_PROPERTIES --flavor=production --sentry=$SENTRY_DSN --apk --aab --deb-gui --deb-cli --asset-dir=/tmp/release
```

```bash
# Build Windows packages (needs to run on a Windows OS)
dart run util/release.dart --flavor=production --sentry=$SENTRY_DSN --exe --msix --asset-dir=/tmp/release
```

```bash
# Publish the packages
dart run utils/release.dart --create --token-file $GITHUB_TOKEN --asset-dir=/tmp/release
```

# Preparing secrets

All packages require [Sentry DSN](https://docs.sentry.io/concepts/key-terms/dsn-explainer/),
write it to a file and pass path to it as `--sentry` argument to `release.dart`.

## Android packages

Create `key.properties` file with the following content:

    storePassword=$STORE_PASSWORD
    keyPassword=$KEY_PASSWORD
    keyAlias=$KEY_ALIAS
    storeFile=path/to/keystore.jks

The `path/to/keystore.jks` path should be absolute, or relative to the `android/app/` directory.

Pass path to the `key.properties` file as `--android-key-properties` argument to `release.dart`

## Publishing to Github

Create a [GitHub access token](https://docs.github.com/en/rest/guides/getting-started-with-the-rest-api?apiVersion=2022-11-28#about-tokens)

Click on your profile icon > `Settings` > `Developer settings` > `Personal access
tokens` > `Tokens` and check the `write:packages` scope.

Write it to a file and pass it to `release.dart` as the `--token-file` argument.


# Android upgrade test

`upgrade_test.dart` checks that data created in the latest published release survives upgrading to
the current code. It downloads the release APK from GitHub, re-signs it with a throwaway test key,
installs it on an emulator, creates repositories in it using [Maestro](https://maestro.dev), then
installs a build of the current code (signed with the same test key) over it and checks that the
repositories still open.

Requirements: a running Android emulator, `ANDROID_HOME` pointing to the Android SDK (with
build-tools), `keytool` and `maestro` on `PATH`.

```bash
dart run util/upgrade_test.dart                 # upgrade from the latest release
dart run util/upgrade_test.dart --from v0.9.4   # upgrade from a specific release
```

The test uninstalls Ouisync from the device first, so it refuses to run on a real device unless
`--allow-real-device` is passed. Downloads, the test key and logs (logcat and Maestro screenshots)
go to `build/upgrade_test/`.

The Maestro flows are in `upgrade_test/`. `seed.yaml` drives the old release and `verify.yaml`
the new build, so the selectors in `seed.yaml` must match the UI of the release being upgraded
from.
