[![CI](https://github.com/equalitie/ouisync-app/actions/workflows/ci.yml/badge.svg)](https://github.com/equalitie/ouisync-app/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-squarte&logo=android&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat-squarte&logo=windows&logoColor=white)

# Ouisync Flutter app

**Secure file-sharing and real-time sync, with or without internet.**

Flutter application that implements the **[Ouisync Flutter plugin](https://github.com/equalitie/ouisync-plugin)**.

<br />
<br />

![OuisyncFull](https://github.com/equalitie/ouisync-app/assets/13749449/5ad03ac1-b614-4726-abec-de550cd2ec91)

<br />

**Ouisync** is a free and open source tool enabling file sync and backups between devices, peer-to-peer.

**Features:**
- 😻 Easy to use: Simply install and quickly create files and folders to sync and share with trusted devices, contacts and/or groups.
- 💸 Free for everyone: no in-app purchases, no subscriptions, no ads, and no tracking!
- 🔆 Offline-first: Ouisync uses an innovative, synchronous, peer-to-peer design that allows users to access and share files and folders whether or not your device can connect to the internet.
- 🔒 Secure: End-to-end encrypted files and folders - both in transit and at rest - secured by established, state-of-the art protocols.
- 🗝 Access Controls: Create repositories that can be shared as read-write, read-only, or blind (you store files for others, but cannot access them).

<br />
<br />

**Operating systems currently supported:**

| OS | GUI | CLI |
|:--- |:---:|:---:|
| Android | Beta | - |
| iOS | :x: | - |
| Linux | Alpha | Beta |
| macOS | :x: | :x: |
| Windows | Alpha | :x: |

**GUI:** Graphic User Interface | **CLI:** Command Line Interface

<br />

**Table of contents**

- [Getting the Ouisync App](#getting-the-ouisync-app)
- [Using this repository](#using-this-repository)
 - [Initialize the Ouisync plugin and Ouisync library submodules](#initialize-the-ouisync-plugin-and-ouisync-library-submodules)
   - [Build the Ouisync library](#build-the-ouisync-library)
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

# Getting the Ouisync App

You can get the app installers for the supported platforms directly from our website at https://ouisync.net/

Or you can use the official app store for each platform in your different devices:
- **Android:**
  - **Google Play Store**: [Ouisync Peer-to-Peer File Sync](https://play.google.com/store/apps/details?id=org.equalitie.ouisync)
- **Windows:**
  - **Microsoft Store**: [Ouisync](https://www.microsoft.com/store/apps/9NVMS5ZRV27F)

<br />

# Using this repository

If you are a developer and want to checkout and build the code, you have two options:

1. Get [**Flutter**](https://flutter.dev/) installed on your computer, the **Andriod SDK**, **Android NDK**, and **Rust**; then clone this repository (this includes        initializing its submodules).

   **For installing Flutter (including Android setup):** You can use the [Get started](https://docs.flutter.dev/get-started/install) guides provided by **Flutter** for      each operating system: [**Windows**](https://docs.flutter.dev/get-started/install/windows), [**macOS**](https://docs.flutter.dev/get-started/install/macos),              [**Linux**](https://docs.flutter.dev/get-started/install/linux), or [**ChromeOS**](https://docs.flutter.dev/get-started/install/chromeos).

   **For installing Rust:** Just follow the instructions from the official website for [**Rust**](https://www.rust-lang.org/), on the [Install](https://www.rust-lang.org/tools/install) section.
   
   You can use the *Dockerfile* for [**Linux**](https://github.com/equalitie/ouisync-app/blob/master/docker/dev/linux/Dockerfile) or [**Windows**](https://github.com/equalitie/ouisync-app/blob/master/docker/dev/windows/Dockerfile), located at [docker/dev](https://github.com/equalitie/ouisync-app/blob/master/docker/dev/), to check all the requierments for building the app and how to do it.

2. Use one of the available *Dockerfile*, for [**Linux**](https://github.com/equalitie/ouisync-app/blob/master/docker/dev/linux/Dockerfile) or [**Windows**](https://github.com/equalitie/ouisync-app/blob/master/docker/dev/windows/Dockerfile), which already contains the development environment required for building the app.

   - If your development platform is **Linux**, you can use the resulting image for creating a container from which you can launch the **Android** app, or the desktop        app.
   
     Also, if you are using **Visual Studio Code** as your **IDE**, you can use the **Visual Studio Code Dev Containers** extension for developing inside the                  container.

   - Unfortunatelly there are some limitations for **Windows** containers, and they are not supported by the **Visual Studio Code Dev Containers** extension; this means      that you can only launch the **Android** app from the container, not the desktop app.
     
     To achieve this, use **adb** to connect your device or emulator via **TCP/IP**. 

     Here are some resources for using **Visual Studio Code** with Docker, and use **adb** for connecting to an Android device using **TCP/IP**: 

     - [How to dockerize Flutter apps](https://blog.codemagic.io/how-to-dockerize-flutter-apps/)
     - [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers)

**NOTE:** Unless otherwise specified, we use the latest version of the **Flutter SDK** in the `stable` channel.

<br />

## Initialize the Ouisync plugin and Ouisync library submodules

The **Ouisync Flutter app** includes in its dependencies the **[Ouisync Flutter plugin](https://github.com/equalitie/ouisync-plugin)** repository as a submodule; at the same time, the **[Ouisync Flutter plugin](https://github.com/equalitie/ouisync-plugin)** depends on the **[Ouisync library](https://github.com/equalitie/ouisync)**, also contained as a submodule in the plugin repository.

In order for the app to properly run, you need to make sure that both submodules are initialized and up to date. This can be achieved by executing the following command while located in the app folder: `git submodule update --init --recursive`

**IMPORTANT:** We use some Flutter packages for various functionalities in the app, so after initializing the submodules, please execute this command to install them: `flutter pub get`

### Linux dependencies

```bash
sudo apt-get install appindicator3-0.1 libsecret-1-dev
```

<br />

### Build the Ouisync library

This app depends on the **[Ouisync Flutter plugin](https://github.com/equalitie/ouisync-plugin)**, which provides the high level `API` for the 
**[Ouisync library](https://github.com/equalitie/ouisync)**, therefor it is required to perform the native library build and the extra initializations described 
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

The **Ouisync Flutter app** uses command arguments to specify a `.<suffix>` variant (don't forget the **"."**), for debuging purposes, or as a way to control the inclusion of some tools in its releases.

Passing the flag `--dart-define=DEV_SUFFIX=.<suffix>` when runing the app, adds the suffix provided to the `applicationId`, `authority`, and application name, so it will install next to the regular app. This suffix is used for testing any new functionality or tools without replacing the regular app installation. 
  
Inside the project folder, you can execute `flutter run --dart-define=DEV_SUFFIX=.dev` for running the app in the default device, and adding the suffix ".dev", for example. 

There are some other useful flags you should checkout (You can find all the available flags in the SDK help: `flutter --help`):

```
flutter run --release // Run the app in release mode

flutter run --verbose // Noisy logging, including all shell commands executed. It can be abbreviate as -v

flutter clean // Delete the build/ and .dart_tool/ directories. Don't forget to run <flutter pub get> right after, to get the packages.

flutter test // Run Flutter unit tests for the current project.

flutter build apk // Build the default executable. By default the resulting **APK** will be a release version.

flutter build appbundle // Build the default app bundle. By default the resulting **AAB** will be a release version.
```

You can also select the device in which you want to run the app, by using the command `flutter devices` to get the list of connected devices:

```
3 connected devices:

Nokia 7 plus (mobile) • 192.168.128.94:5555 • android-arm64  • Android 10 (API 29)
Windows (desktop)     • windows             • windows-x64    • Microsoft Windows [Version 10.0.22621.2134]
Chrome (web)          • chrome              • web-javascript • Google Chrome 115.0.5790.171
Edge (web)            • edge                • web-javascript • Microsoft Edge 116.0.1938.54
```

Then you can just use the device name from the second column, like this: `flutter run -d windows`; and with a suffix: `flutter run -d 192.168.128.94:5555 --dart-define=DEV_SUFFIX=.dev` 

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

# Sentry

**Ouisync** integrates **Sentry**, via the `sentry_flutter` plugin. 

For initialization, you need to get a client key, called **DSN**, from a **Sentry** instance, making it available via an `.env` file, or as a environment variable using `export`, and then using [envied](https://github.com/petercinibulk/envied)

Please follow the instructions in the package repository for [envied in GitHub](https://github.com/petercinibulk/envied#table-of-contents) to add a key called `DSN`, that contains the client key.

**IMPORTANT:** Don't forget to add both `.env` and `env.g.dart` files to your `.gitignore` file. 

You can also skip this step if you are not interested on using **Sentry**.

<br />

# Troubleshooting

<br />

### Specify paths to sub-commands: **`rustc`** and **`cargo`**

The **[Ouisync Flutter plugin](https://github.com/equalitie/ouisync-plugin)**, that provides the API for using the **[Ouisync library](https://github.com/equalitie/ouisync)** that is written in **`Rust`**, uses **`Cargo`** for building it.

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

## How to add localized strings

We use the package **intl_utils** for handling the localization of the strings used in the app.

To add a new localized string, modify the [English `.arb` file](lib/l10n/intl_en.arb), and run:

```bash
dart run intl_utils:generate
```

Then use it as such:

```
import '../../../generated/l10n.dart';

...
...
...

Text(S.current.hello);
```


**NOTE:** For translations to any other language, please create a new issue in this repository, so we can take care of it.
