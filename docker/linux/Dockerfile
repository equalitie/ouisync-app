# We are using the stable release of the Docker image for Flutter from CirusCI:
# https://hub.docker.com/r/cirrusci/flutter/tags
FROM cirrusci/flutter:stable as pre-build

ARG build_name
ARG build_number
ARG keystore
ARG keystore_password_file
ARG ndk_version
ARG branch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends cmake ninja-build clang build-essential pkg-config libgtk-3-dev liblzma-dev lcov libclang-dev gzip appindicator3-0.1 fuse libfuse-dev

# There is a conflict between libayatana-appindicator3-1 and libappindicator3-dev that causes the installation of the later to fail;
# so we first remove the conflicting library, then add the one we need.
RUN apt purge -y libayatana-appindicator3-1 && \
    apt install -y libappindicator3-dev

RUN flutter config --enable-linux-desktop

# We use version 22.0.7026061 of the Android SDK since it is the latest stable version without compatibility issues for some of the libraries we use
RUN echo "Installing Android NDK version $ndk_version" && \
    cd opt/android-sdk-linux/cmdline-tools/latest/bin/ && \
    sdkmanager --install "ndk;$ndk_version"

# Symlink to the current Python version
RUN ln -s /usr/bin/python3 /usr/bin/python

# Installing rustup and cargo, updating the PATH variable, then adding targets for Android
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH "/root/.cargo/bin:$PATH"

RUN rustup target add aarch64-linux-android && \
    rustup target add armv7-linux-androideabi && \
    rustup target add x86_64-linux-android && \
    rustup target add aarch64-unknown-linux-gnu && \
    rustup target add armv7-unknown-linux-gnueabihf

RUN mkdir -p /home/code
WORKDIR /home/code/

# We can pass the specific commit we want to checkout, as a parameter
RUN echo "Checking out branch $branch" && \
    git clone https://github.com/equalitie/ouisync-app && git -C ouisync-app checkout $branch && \
    cd ouisync-app && \
    git submodule update --init --recursive

# Gradle will use local.properties when building the Android APKs to find the location to the toolchains
RUN echo "ndk.dir=/opt/android-sdk-linux/ndk/$ndk_version" >> /home/code/ouisync-app/android/local.properties
RUN echo "rust.rustcCommand=/root/.cargo/bin/rustc" >> /home/code/ouisync-app/android/local.properties
RUN echo "rust.cargoCommand=/root/.cargo/bin/cargo" >> /home/code/ouisync-app/android/local.properties

# In this Docker image for Flutter from CirusCI, ffigen can't find the path to libclang.so, so we need to add it to the package configuration
RUN echo "  llvm-path: ['/usr/lib/llvm-14/lib/libclang.so']" >> /home/code/ouisync-app/ouisync-plugin/pubspec.yaml

FROM pre-build as build

# Building the OuiSync library and generating the bindings for the OuiSync plugin
RUN cd ouisync-app/ouisync-plugin/ouisync && \
    cargo build --release --lib && \
    cargo run --bin bindgen

RUN cd ouisync-app/ouisync-plugin/ && \
    flutter pub get && \
    flutter pub run ffigen

# Building the Android APK that later we'll use to create the app bundle
RUN cd ouisync-app/ && \
    flutter pub get && \
    flutter build apk --release

# We use the provided keystore and plain file with the keystore password to sign the app bundle for Android;
# Then we build the Linux version of the app, the Linux version of the CLI, and move it to a common location
# for retrieval at the end of the process.

FROM build as release

ARG build_name
ARG build_number
ARG keystore
ARG keystore_password_file

WORKDIR /home/code/ouisync-app/util/

# Copying the keystore and keystore password file into the container
COPY ${keystore} .
COPY ${keystore_password_file} .

WORKDIR /home/code/ouisync-app/

# Signing the Android APK and building the app bundle (AAB)
RUN ./util/build-signed-release.sh ${build_name} ${build_number} ./util/${keystore} ./util/${keystore_password_file} "y"

RUN git_commit=$(git rev-parse --short HEAD) && \
    date_tag=$(date -u "+%Y-%m-%d--%H-%M-%S--UTC") && \
    tags="$(printf '%05d' ${build_number})--v${build_name}--${date_tag}--${git_commit}" && \
    release_dir="release--${tags}" && \
    #Creating the destination folders for the binaries
    mkdir -p /home/releases/$release_dir/android-$tags, /home/releases/$release_dir/linux-cli-$tags, /home/releases/$release_dir/linux-desktop-$tags && \
    # Building Linux Desktop version
    flutter build linux --release && \
    tar -cjf /home/releases/$release_dir/linux-desktop-$tags/linux-desktop-${tags}.tar.bz2 /home/code/ouisync-app/build/linux/x64/release/bundle/* && \
    # Building Linux CLI version
    cd /home/code/ouisync-app/ouisync-plugin/ouisync/ && \
    cargo build --release --bin ouisync && \
    tar -cjf /home/releases/$release_dir/linux-cli-$tags/linux-cli-${tags}.tar.bz2 /home/code/ouisync-app/ouisync-plugin/ouisync/target/release/* && \
    # Copying the Android binaries to the release folder
    cp -r /home/code/ouisync-app/releases/${release_dir}/* /home/releases/${release_dir}/android-${tags}/
