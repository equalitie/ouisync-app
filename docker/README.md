# OuiSync Docker Build

## Linux container
To create an image that builds OuiSync for Android (APK, AAB), Linux desktop, and Linux CLI, you need to run the build command and pass the parameters used to 
sign the bundle: `build_name`, `build_number`, `keystore` (full path), and `keystore_password_file` (full path).

Also provide the Android NDK version required, and the branch: `ndk_version`, `branch`

**Important:** Before building the `Dockerfile`, remember to place the keystore (`.jks` file), and the keystore password file (`.txt` file), in the same 
location that the `Dockerfile`, which is the one from where the build command is being executed.

#### build name
A version triple such as `0.0.1` or `0.0.1-rc1`

#### build number
An identifier used as an internal version number.
Each build must have a unique identifier to differentiate it from previous builds.

**Note:** you can run `flutter build appbundle -h` for more info

#### keystore
Name of the keystore used for signing the app bundle (`.jks` file). 

#### keystore password file
Name of the file containing the password to unlock the keystore (`.txt` file).

#### ndk_version
The Android NDK version to use (i.e.: 22.0.xxxxxxx)

#### branch
The repository branch to checkout for the build

Run this command:

`sudo docker build --build-arg build_name=<build-name> --build-arg build_number=<build-number> --build-arg keystore=<keystore-name> --build-arg keystore_password_file=<password-file-name> --build-arg ndk_version=<ndk-version> --build-arg branch=<bbranch>  -t <tag> .`

**Note:** By default, docker will run using **BuildKit**. If you want to dissable it, just add `DOCKER_BUILDKIT=0` at the beginning of the command, right between `sudo` and `docker`
