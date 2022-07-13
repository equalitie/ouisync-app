# OuiSync Docker Build

## Android Bundle (Linux)
To create an image that builds OuiSync for Android and generates a signed bundle file (.aab), you need to run the build command and pass the parameters used to sign the bundle: build name, buiild number, keystore, and keystore password file.

**Important:** Before building the `Dockerfile`, remember to place the keystore (`.jks` file), and the keystore password file (`.txt` file), in the same location that the `Dockerfile`, which is the one from where the build command is being executed.

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

Run this command:

`sudo docker build --build-arg build_name=0.0.1 --build-arg build_number=1 --build-arg keystore=upload-keystore.jks --build-arg keystore_password_file=docker-password.txt --build-arg output_destination=/Users/jorgepabon/Dockers/ouisync_linux_full  -t custom-full .`

**Note:** By default, docker will run using **BuildKit**. If you want to dissable it, just add `DOCKER_BUILDKIT=0` at the beginning of the command, right between `sudo` and `docker`