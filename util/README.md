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

