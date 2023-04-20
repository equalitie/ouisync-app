# We are using the stable release of the Docker image for Flutter from CirusCI:
# https://hub.docker.com/r/cirrusci/flutter/tags
FROM ubuntu:20.04 as pre-build

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends cmake ninja-build clang build-essential pkg-config libgtk-3-dev \
    liblzma-dev lcov libclang-dev gzip appindicator3-0.1 fuse libfuse-dev git curl unzip wget android-sdk \
    libsecret-1-dev libsecret-tools libsecret-1-0
    # android-tools-adb

ENV ANDROID_HOME "/usr/lib/android-sdk"

# There is a conflict between libayatana-appindicator3-1 and libappindicator3-dev that causes the installation of the later to fail;
# so we first remove the conflicting library, then add the one we need.
RUN apt purge -y libayatana-appindicator3-1 && \
    apt install -y libappindicator3-dev

# Removing old CMake and installing dependencies
RUN apt remove -y cmake && \
    apt install -y build-essential libssl-dev
    
WORKDIR /home/

## Installing latest CMake (3.26.3)
ADD https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3.tar.gz .

RUN tar -zxvf cmake-3.26.3.tar.gz
    
RUN cd cmake-3.26.3 && \
    ./bootstrap

# WORKDIR /home/cmake-3.26.3/

RUN make && \
    make install && \
    cmake --version


ADD https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip .

RUN unzip commandlinetools-linux-9477386_latest.zip -d cmdline-tools \
&& mv cmdline-tools/* "${ANDROID_HOME}/cmdline-tools/"

ENV PATH "$ANDROID_HOME/cmdline-tools/bin:$PATH"

# Installing Android SDK (33), platform tools, build tools (30.0.5), command line tools (latest) and NDK (25.2.9519653) and other components

RUN yes | sdkmanager "platform-tools" "platforms;android-33" "build-tools;30.0.3" "cmdline-tools;latest" "ndk;25.2.9519653" --sdk_root="${ANDROID_HOME}"

# Installing flutter (stable)

RUN git clone -b stable https://github.com/flutter/flutter.git /opt/flutter

ENV PATH "/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

RUN flutter config --no-analytics && \
    flutter config --enable-linux-desktop

RUN yes | flutter doctor --android-licenses

RUN flutter doctor

# # Symlink to the current Python version
# RUN ln -s /usr/bin/python3 /usr/bin/python

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

RUN echo "Checking out master branch" && \
    git clone https://github.com/equalitie/ouisync-app && git -C ouisync-app checkout master && \
    cd ouisync-app && \
    git submodule update --init --recursive

# # Gradle will use local.properties when building the Android APKs to find the location to the toolchains
RUN echo "rust.rustcCommand=/root/.cargo/bin/rustc" >> /home/code/ouisync-app/android/local.properties
RUN echo "rust.cargoCommand=/root/.cargo/bin/cargo" >> /home/code/ouisync-app/android/local.properties

FROM pre-build as build

# Building the OuiSync library and generating the bindings for the OuiSync plugin
RUN cd ouisync-app/ouisync-plugin/ouisync && \
    cargo build --release -p ouisync-ffi && \
    cargo run --bin bindgen

RUN cd ouisync-app/ouisync-plugin/ && \
    flutter pub get && \
    flutter pub run ffigen

# Installing flutter_secure_storage extra dependencies
RUN apt install -y  libsecret-1-dev libsecret-tools libsecret-1-0



# RUN cd /ouisync-app/ && \
#     flutter clean && \
#     flutter pub get

# ENV SRC_DIR=/root/home/adb-linux

# WORKDIR $SRC_DIR

# COPY . .

# RUN apt update -y && apt install -y --no-install-recommends android-tools-adb