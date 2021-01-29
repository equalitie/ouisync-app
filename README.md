# ouisync-app

OuiSync Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## How to limit the Android building task to specific ABIs

In cases in which we only want to build the code for specifics ABIs on **Android**, we make use of the `local.properties` file (This file **_must not_** be commited into the repository. If we want to build for **_all_** the supported ABIs, the referenced property is not needed).

In the `local.properties` file (located at: `./android/local.properties`), we can list the ABIs we want to support/build, separated by '**,**' (coma):

```ndk.abiFilters=x86,x86_64,armeabi-v7a```

## Boost for Android required configurarion for archiver on MacOS

Because the tools in **MacOS** for C/C++ are Apple versions (clang, clang++, ar, etc.); it is necessary to use the Android NDK toolset versions, according to each ABI supported in the app.

We need to modify the jam file containing the configuration for Android: `user-config-android.jam` 
(located at: `./ios/ouisync/cmake/build-boost/inline-boost/user-config-android.jam`). This values then will be used by the **b2** (Boost.Build) to compile the Boost library: 

We achieve thisby adding the `<ranlib>` tag, right after the `<archiver>` tag in the jam file:

```
...
using clang : $(Architecture) : $(CompilerFullPath) :
<archiver>$(BinutilsPrefix)ar
<ranlib>$(BinutilsPrefix)ranlib
...
```
