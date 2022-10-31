[![CI](https://github.com/equalitie/ouisync-app/actions/workflows/ci.yml/badge.svg)](https://github.com/equalitie/ouisync-app/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-squarte&logo=android&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat-squarte&logo=windows&logoColor=white)

# OuiSync Flutter app

**Secure file-sharing and real-time sync, with or without internet.**

Flutter application that implements the **[OuiSync Flutter plugin](https://github.com/equalitie/ouisync-plugin)**.

<br />
<br />

![OuiSync](https://ouisync.net/assets/img/logo.png)

<br />

**OuiSync** is a free and open source tool enabling file sync and backups between devices, peer-to-peer.

**Features:**
- 😻 Easy to use: Simply install and quickly create files and folders to sync and share with trusted devices, contacts and/or groups.
- 💸 Free for everyone: no in-app purchases, no subscriptions, no ads, and no tracking!
- 🔆 Offline-first: OuiSync uses an innovative, synchronous, peer-to-peer design that allows users to access and share files and folders whether or not your device can connect to the internet.
- 🔒 Secure: End-to-end encrypted files and folders - both in transit and at rest - secured by established, state-of-the art protocols.
- 🗝 Access Controls: Create repositories that can be shared as read-write, read-only, or blind (you store files for others, but cannot access them).

<br />
<br />

**Operating systems currently supported:**

| OS | Supported | Notes |
|:--- |:---:|:---|
| Android | :white_check_mark: | Early access |
| iOS | :x: |
| Linux | :x: |
| macOS | :x: |
| Windows | :ballot_box_with_check: | Available soon |

:ballot_box_with_check:: Some functionalities are not yet available.

<br />

**Table of contents**

- [Getting the OuiSync App](#getting-the-ouisync-app)
- [Using this repository](#using-this-repository)
 - [Initialize the OuiSync plugin and OuiSync library submodules](#initialize-the-ouisync-plugin-and-ouisync-library-submodules)
   - [Build the OuiSync library](#build-the-ouisync-library)
   - [Run the tests](#run-the-tests)
 - [How to run the app from the command line](#how-to-run-the-app-from-the-command-line)
   - [Flutter](#flutter)
   - [Android (using Gradle)](#android-using-gradle)
     - [How to build for specific ABIs in Android](#how-to-build-for-specific-abis-in-android)
- [Troubleshooting](#troubleshooting)
   - [Specify paths to sub-commands: **`rustc`** and **`cargo`**](#specify-paths-to-sub-commands-rustc-and-cargo)
   - [Specify the path to the **Android NDK**](#specify-the-path-to-the-ndk)
- [License](https://github.com/equalitie/ouisync-app/blob/master/LICENSE)

---

<br />

# Getting the OuiSync App

You can get the app installers for the supported platforms directly from our website at https://ouisync.net/

Or you can use the official app store for each platform in your different devices:
- **Android:**
  - **Google Play Store**: [OuiSync Peer-to-Peer File Sync](https://play.google.com/store/apps/details?id=org.equalitie.ouisync) (currently in early access)
- **Windows**
  - [**Windows Apps**](https://www.microsoft.com/en-us/store/apps/windows): Coming soon.

<br />

# Using this repository

If you are a developer and want to checkout the code, there are two things that you need to do before being able to run the code: Get [Flutter](https://flutter.dev/) installed in your computer, and clone this repository (this includes initializing its submodules).

For the first step, you can use the [Get started](https://docs.flutter.dev/get-started/install) guides provided by Flutter for each operating system: [Windows](https://docs.flutter.dev/get-started/install/windows), [macOS](https://docs.flutter.dev/get-started/install/macos), [Linux](https://docs.flutter.dev/get-started/install/linux), or [ChromeOS](https://docs.flutter.dev/get-started/install/chromeos).

**NOTE:** Unless otherwise specified, we use the latest version of the Flutter SDK in the `stable` channel.

<br />

## Initialize the OuiSync plugin and OuiSync library submodules

The **OuiSync Flutter app** includes in its dependencies the **[OuiSync Flutter plugin](https://github.com/equalitie/ouisync-plugin)** repository as a submodule; at the same time, the **[OuiSync Flutter plugin](https://github.com/equalitie/ouisync-plugin)** depends on the **[OuiSync library](https://github.com/equalitie/ouisync)**, also contained as a submodule in the plugin repository.

In order for the app to properly run, you need to make sure that both submodules are initialized and up to date. This can be achieved by executing the following command while located in the app folder: `git submodule update --init --recursive`

**IMPORTANT:** We use some Flutter packages for various functionalities in the app, so after initializing the submodules, please execute this command to install them: `flutter pub get`

<br />

### Build the OuiSync library

This app depends on the **[OuiSync Flutter plugin](https://github.com/equalitie/ouisync-plugin)**, which provides the high level `API` for the 
**[OuiSync library](https://github.com/equalitie/ouisync)**, therefor it is required to perform the native library build and the extra initializations described 
in the plugin README file.

- [Building the native library](https://github.com/equalitie/ouisync-plugin#building-the-native-library)
- [Before using/building this plugin](https://github.com/equalitie/ouisync-plugin#before-usingbuilding-this-plugin)

<br />

### Run the tests

Before running the tests, please copy/symlink the native library to:

- Linux: `build/test/libouisync.so`
- macOS: `build/test/libouisync.dylb`
- Windows: `build/test/ouisync.dll`

<br />

## How to run the app from the command line

You can run the app from the command line and make use of different flags to obtain more information about the building process in cases in which you want to troubleshoot any issue, or simply get the full log of the process.

<br />

### Flutter

The Ouisync app implements some build variants, specifically product flavors, as a way to control the inclusion of some tools in its releases.

Currently, there are three (3) flavors:

- **vanilla**: regular code base, no extra tooling.
- **analytics**: regular code base, includes Firebase Crashlytics **ON** by default.
- **development**: This flavor is used for testing any new functionality or tools without replacing the regular app installation (**vanilla** or **analytics**). It has a different `applicationId` and `authority` for the content provider, so it will install next to the regular app.
  
Inside the project folder, you can execute `flutter run --flavor vanilla -t lib/main_vanilla.dart` for running the app in the default device (replacing the flavor and target accordingly). 

There are some other useful flags you should checkout (You can find all the available flags in the SDK help: `flutter --help`):

```
flutter run --flavor vanilla -t lib/main_vanilla.dart --release // Run the app in release mode

flutter run --flavor vanilla -t lib/main_vanilla.dart --verbose // Noisy logging, including all shell commands executed. It can be abbreviate as -v

flutter clean // Delete the build/ and .dart_tool/ directories. Don't forget to run <flutter pub get> right after, to get the packages.

flutter test // Run Flutter unit tests for the current project.

flutter build apk --flavor vanilla -t lib/main_vanilla.dart // Build the default executable. By default the resulting **APK** will be a release version.

flutter build appbundle --flavor vanilla -t lib/main_vanilla.dart // Build the default app bundle. By default the resulting **AAB** will be a release version.
```

You can also select the device in which you want to run the app, by using the command `flutter devices` to get the list of connected devices:

```
3 connected devices:

Windows (desktop) • windows • windows-x64    • Microsoft Windows [Version 10.0.19044.1645]
Chrome (web)      • chrome  • web-javascript • Google Chrome 100.0.4896.127
Edge (web)        • edge    • web-javascript • Microsoft Edge 100.0.1185.36
```

Then you can just use the device name from the second column, like this: `flutter run --flavor vanilla -t lib/main_vanilla.dart -d windows`

<br />

### Android (using Gradle)

Inside the `android` folder, you can execute this command `./gradlew assembleDebug` to tun the app in your Android device or emulator (This will build the app in debug mode)

Maybe add some flags, in order to get more information during the process:

```
./gradlew assembleDebug --info --debug --stacktrace
```
You can use one, all, or a combination of them for different results.

**NOTE**: For a list of the default Gradle tasks available for the project, you can use this command: `./gradlew tasks`

Add the flag `--all` for more information:

```
./gradlew tasks --all
```
For a detailed explanation on the different flags and its results, please refer to the oficial documentation => <https://docs.gradle.org/current/userguide/command_line_interface.html>

<br />

#### How to build for specific ABIs in Android

In cases in which we only want to build for specifics ABIs on **Android**, we make use of the `local.properties` file.

In the `local.properties` file (located at: `./android/local.properties`), we can list the ABIs we want to support/build, separated by '**,**' (comma), no spaces, like this:

```
ndk.abiFilters=x86,x86_64,armeabi-v7a,arm64-v8a
```
If we want to build for **_all_** the supported ABIs, this property is not needed, or can be left empty.

**IMPORTANT**: **_do not_** commit `local.properties` into the repository; include it in the `.gitignore` file.

<br />

# Troubleshooting

<br />

### Specify paths to sub-commands: **`rustc`** and **`cargo`**

The **[OuiSync Flutter plugin](https://github.com/equalitie/ouisync-plugin)**, that provides the API for using the **[OuiSync library](https://github.com/equalitie/ouisync)** that is written in **`Rust`**, uses **`Cargo`** for building it.

If building the app in your computer you encounter this error:

```
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':ouisync_plugin:cargoBuildArm'.
> A problem occurred starting process 'command 'rustc''

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output. Run with --scan to get full insights.

* Get more help at https://help.gradle.org

BUILD FAILED in 2s
```

It means that **`Gradle`** can't find **`rustc`** when trying to run the command to build the plugin.

To fix this, add the following to the `local.properties` file located in the `android` folder of the app project (`~/android/local.properties`):

```
rust.rustcCommand=<path-to-user-folder>/.cargo/bin/rustc
rust.cargoCommand=<path-to-user-folder>/.cargo/bin/cargo
```

Don't forget to replace `<path-to-user-folder>` with the path to your user folder.

<br />

### Specify the path to the **NDK**

**Rust** needs the Android toolsets in orden to compile properly.

For this add the path to the `NDK` installation to the `local.properties` file:

```
ndk.dir=<path-to-ndk-installation>
```
