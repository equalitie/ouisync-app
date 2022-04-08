[![CI](https://github.com/equalitie/ouisync-app/actions/workflows/ci.yml/badge.svg)](https://github.com/equalitie/ouisync-app/actions/workflows/ci.yml)

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


## Update the **OuiSync** plugin and **OuiSync** (**Rust**) library submodules 

The **`OuiSync`** app includes in its dependencies the **`OuiSync`** plugin repository as a submodule; at the same time, the **`OuiSync`** plugin depends on the **`OuiSync`** library, also contained as a submodule in the plugin repository.

In order for the **`OuiSync`** app to properly run, you need to make sure that both submodules are updated. This can be achieved by executing the following command while located in the app folder:

```
git submodule update --init --recursive
```


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


## Run linter

```
flutter analyze
```

## How to build for specific ABIs in Android

In cases in which we only want to build for specifics ABIs on **Android**, we make use of the `local.properties` file.

In the `local.properties` file (located at: `./android/local.properties`), we can list the ABIs we want to support/build, separated by '**,**' (comma), no spaces, like this:

```
ndk.abiFilters=x86,x86_64,armeabi-v7a,arm64-v8a
```
If we want to build for **_all_** the supported ABIs, this property is not needed, or can be left empty.

**IMPORTANT**: **_do not_** commit `local.properties` into the repository; include it in the `.gitignore` file.


## Specify paths to sub-commands: **`rustc`** and **`cargo`**

The **`OuiSync`** plugin, that provides the API for using the **`OuiSync`** library that is written in **`Rust`**, uses **`Cargo`** for building it.

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

## Specify the path to the **NDK**

**Rust** needs the Android toolsets in orden to compile properly. 

For this add the path to the `NDK` installation to the `local.properties` file:

```
ndk.dir=<path-to-ndk-installation>
```
