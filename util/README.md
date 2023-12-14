# Creating a release

## Prerequisities

Create `android/key.properties` with the following content:

    storePassword=$STORE_PASSWORD
    keyPassword=$KEY_PASSWORD
    keyAlias=upload
    storeFile=path/to/keystore.jks

(Note in our case `$STORE_PASSWORD` and `$KEY_PASSWORD` are the same). Do not commit this file to
the source control (it should already be in `.gitignore`).

The `path/to/keystore.jks` path should be absolute, or relative to the `android/app/` directory.

Additionally, create a [GitHub access
token](https://docs.github.com/en/rest/guides/getting-started-with-the-rest-api?apiVersion=2022-11-28#about-tokens)

Click on your profile icon > Settings > Developer settings > Personal access
tokens > Tokens. Check the `write:packages` and `delete:packages` scopes
(without the latter you won't be able to upload more assets using the script).

and put it into a file somewhere, you'll pass it to the release script as an
argument. Again, don't commit it.

## Creating a release

Bump the app version in `pubspec.yaml`. The version has the following format:

    MAJOR.MINOR.PATH{-PRE}+BUILD

Where `MAJOR`, `MINOR` and `PATCH` are the coresponding semver components, `PRE` is an optional
pre-release tag (e.g. `alpha`, `beta`, `rc1`, `rc2`, ...) and `BUILD` is the build number. The build
number must be incremented for every release. The other components are just for user information
and can be set to anything but ideally we should follow established practices (i.e., semver).

Then run the provided `release.dart` script from the project root:

    dart pub get
    dart run utils/release.dart --create -t path/to/github/token/file

Notes:

- Omitting the github token still creates the release packages but doesn't upload them to github.

## Publishing the release

Go to [github releases](https://github.com/equalitie/ouisync-app/releases), edit the draft release,
(add release notes, etc..) and when happy, publish it.
