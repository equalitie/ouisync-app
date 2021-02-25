# ouisync-app

OuiSync Flutter application.

# How to run the code



## Make sure the Flutter environment is ready

Once you have cloned the repository, first execute the following command from the terminal, while inside the project folder:

```
flutter doctor 
```
Read the report and confirm that there are not problems with the Flutter installation, as well as the development tools (SDKs, emulators, IDE, etc.).
Please check the oficial Flutter documentation for any issues or doubts => <https://flutter.dev/docs>


## Get Flutter up to date

If you already have a Flutter installation, execute this command in the terminal to upgrade Flutter to the latest version:

```
flutter upgrade
```
**NOTE**: Make sure that you are in the `stable` channel.


## Get the libraries included in pubspec.yaml

OuiSync uses some Flutter packages for various functionalities, so please execute this command to install them:

```
flutter pub get
```


## How to run the app from the command line

You can run the app from the command line and make use of different flags to obtain more information about the building process in cases in which you want to troubleshoot any issue, or simply get the full log of the process.


### Running the Android app from the command line with Gradle

Inside the `android` folder, you can execute this command:

```
./gradlew assembleDebug
```
This will build the app in debug mode. 
Maybe add some flags, in order to get more information during the process:

```
./gradlew assembleDebug --info --debug --stacktrace
```
You can use one, all, or a combination of them for different results.

**NOTE**: For a list of the default Gradle tasks available for the project, you can use this command:

```
./gradlew tasks 
```

Add the flag `--all` for more information:

```
./gradlew tasks --all
```
For a detailed explanation on the different flags and its results, please refer to the oficial documentation => <https://docs.gradle.org/current/userguide/command_line_interface.html>


## Running the app from the command line with Flutter

Inside the project folder, you can execute this command:

```
flutter run
```
This will build the app in debug mode.

You can also add the flag `--verbose` to get more information during the process:

```
flutter run --verbose
```
For more information about the command line interface in Flutter, please refer to the oficial documentation => 
<https://flutter.dev/docs/reference/flutter-cli>

**NOTE**: If you ever need to clean the build cache, you can use this command:

```
flutter clean
```
This will delete the `dart-tools` folder, `android` folder, and `ios` folder.


## How to build for specific ABIs in Android

In cases in which we only want to build for specifics ABIs on **Android**, we make use of the `local.properties` file.

In the `local.properties` file (located at: `./android/local.properties`), we can list the ABIs we want to support/build, separated by '**,**' (comma), no spaces, like this:

```
ndk.abiFilters=x86,x86_64,armeabi-v7a,arm64-v8a
```
If we want to build for **_all_** the supported ABIs, this property is not needed, or can be left empty.

**IMPORTANT**: **_do not_** commit `local.properties` into the repository; include it in the `.gitignore` file.


## Boost for Android required configuration for archiver on MacOS (Darwin toolset)

Because the tools in **MacOS** for C/C++ are Apple versions (`clang`, `clang++`, `ar`, etc.); it is necessary to use the Android NDK toolset versions, according to each ABI supported in the app.

We need to modify the jam file containing the configuration for Android: `user-config-android.jam` (located at `./ios/ouisync/cmake/build-boost/inline-boost/user-config-android.jam`). 
These values then will be used by **b2** (Boost.Build) to compile the Boost library.

We achieve this by adding the `<ranlib>` tag, right after the `<archiver>` tag in the jam file:

```
...
using clang : $(Architecture) : $(CompilerFullPath) :
<archiver>$(BinutilsPrefix)ar
<ranlib>$(BinutilsPrefix)ranlib
...
```
