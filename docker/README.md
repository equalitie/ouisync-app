# Ouisync Docker Build

## Linux container
To create an image that builds **Ouisync** for **Android** (**APK**, **AAB**), **Linux desktop**, and **Linux CLI**, you need to run the build command and 
pass the parameters used to sign the bundle: `build_name`, `build_number`, `keystore` (file name), and `keystore_password_file` (file name).

Also provide the **Android NDK** version required. for compiling the app, and the branch to checkout for the building process: `ndk_version`, `branch`

#### **build name**
A version triple such as `0.0.1` or `0.0.1-rc1`

#### **build number**
An identifier used as an internal version number.
Each build must have a unique identifier to differentiate it from previous builds.

**Note:** you can run `flutter build appbundle -h` for more info

#### **keystore**
Name of the keystore used for signing the app bundle (`.jks` file). It must be in the same location from which the build command is executed.

#### **keystore password file**
Name of the file containing the password to unlock the keystore (`.txt` file). It must be in the same location from which the build command is executed.

#### **ndk_version**
The **Android NDK** version to use (i.e.: `22.0.xxxxxxx`)

#### **branch**
The repository branch to checkout for the build

## Building the Linux image

In order to build the image from the **Dockerfile**, you can run this command:

`sudo docker build --build-arg build_name=<build-name> --build-arg build_number=<build-number> --build-arg keystore=<keystore-name> --build-arg keystore_password_file=<password-file-name> --build-arg ndk_version=<ndk-version> --build-arg branch=<branch>  -t <tag> .`

**Important:** Before building the **Dockerfile**, remember to place the keystore (`.jks` file), and the keystore password file (`.txt` file), in the same 
location from which you are executing the build command. 

If the **Dockerfile** is not in this location, then you can use the `-f` flag to provide the location of the **Dockerfile**. 
The previous command would look like this:

`sudo docker build --build-arg build_name=<build-name> --build-arg build_number=<build-number> --build-arg keystore=<keystore-name> --build-arg keystore_password_file=<password-file-name> --build-arg ndk_version=<ndk-version> --build-arg branch=<branch> -f <dockerfile-location> -t <tag> .`

**Note:** By default, docker will run using **BuildKit**. If you want to dissable it, just add `DOCKER_BUILDKIT=0` at the beginning of the command, right 
between `sudo` and `docker`
