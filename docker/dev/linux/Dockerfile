FROM ubuntu:20.04 as tools

# No user prompts when installing dependencies
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends cmake ninja-build clang build-essential pkg-config libgtk-3-dev \
    liblzma-dev lcov libclang-dev gzip appindicator3-0.1 fuse libfuse-dev git curl unzip wget android-sdk \
    libsecret-1-dev libsecret-tools libsecret-1-0 python

# Update ANDROID_HOME with the Android SDK path
ENV ANDROID_HOME "/usr/lib/android-sdk"

# There is a conflict between libayatana-appindicator3-1 and libappindicator3-dev that causes the installation of the later to fail;
# so we first remove the conflicting library, then add the one we need.
RUN apt purge -y libayatana-appindicator3-1 && \
    apt install -y libappindicator3-dev

FROM tools as update-cmake

# Remove old CMake and install dependencies
RUN apt remove -y cmake && \
    apt install -y build-essential libssl-dev

# Create new folder for installers
RUN mkdir -p /home/TEMP/

WORKDIR /home/TEMP/

## Download latest CMake (3.26.3)
ADD https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3.tar.gz .

# Extract into /home/TEMP/cmake-3.26.3
RUN tar -zxvf cmake-3.26.3.tar.gz
    
# Bootstrap CMake
RUN cd cmake-3.26.3 && \
    ./bootstrap

# Make and install CMAKE
RUN cd cmake-3.26.3 && \
    make && \
    make install && \
    cmake --version

FROM update-cmake as android

# Download Android command line tools (latest)
ADD https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip .

# Extract into /home/TEMP/cmdline-tools/ and move to ANDROID_HOME/cmdline-tools/
RUN unzip commandlinetools-linux-9477386_latest.zip -d cmdline-tools \
&& mv cmdline-tools/* "${ANDROID_HOME}/cmdline-tools/"

# Update PATH with the Android command line tools location
ENV PATH "$ANDROID_HOME/cmdline-tools/bin:$PATH"

# Install Android SDK (33), platform tools, build tools (30.0.5), command line tools (latest) and NDK (25.2.9519653) and other components
RUN yes | sdkmanager "platform-tools" "platforms;android-33" "build-tools;30.0.3" "cmdline-tools;latest" "ndk;25.2.9519653" --sdk_root="${ANDROID_HOME}"

FROM android as rust

# Install rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Update PATH with rustup and cargo root location
ENV PATH "/root/.cargo/bin:$PATH"

# Add the targets for the supported platforms (Note: The target for the platform running the rustup installation (Window, Linux, Mac) was already added by the installer)
RUN rustup target add aarch64-linux-android && \
    rustup target add armv7-linux-androideabi && \
    rustup target add x86_64-linux-android && \
    rustup target add aarch64-unknown-linux-gnu && \
    rustup target add armv7-unknown-linux-gnueabihf

FROM rust as flutter

# Create folder for Flutter (stable)
RUN mkdir -p /opt/

# Clone Flutter (stable) into /opt/flutter
RUN cd /opt/ && \
    git clone -b stable https://github.com/flutter/flutter.git

RUN ls /opt
RUN ls /opt/flutter

# Update PATH with the Flutter and Dart locations
ENV PATH "/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH"

# Flutter configurations
RUN flutter config --no-analytics
RUN flutter config --enable-linux-desktop
RUN yes | flutter doctor --android-licenses

RUN flutter doctor

FROM flutter as ouisync-code

# Create directory for the code
RUN mkdir -p /home/code

WORKDIR /home/code/

# Clone the ouisync-app repository and initialize its submodules (ouisync-plugin, ouisync)
RUN echo "Checking out master branch" && \
    git clone https://github.com/equalitie/ouisync-app && git -C ouisync-app checkout master && \
    cd ouisync-app && \
    git submodule update --init --recursive

# Update android\local.properties with the location to rustc and cargo
RUN echo "rust.rustcCommand=/root/.cargo/bin/rustc" >> /home/code/ouisync-app/android/local.properties
RUN echo "rust.cargoCommand=/root/.cargo/bin/cargo" >> /home/code/ouisync-app/android/local.properties

# Build the ouisync library and generate the bindings
RUN cd ouisync-app/ouisync-plugin/ouisync && \
    cargo build --release -p ouisync-service && \
    cargo run --bin bindgen

# Get the plugin dependencies and generate the bindings for the library headers
RUN cd ouisync-app/ouisync-plugin/ && \
    flutter pub get && \
    flutter pub run ffigen

# Get the app dependencies
RUN cd ouisync-app && \
    flutter pub get

# Remove all the installers
RUN rm /home/TEMP -r

WORKDIR /home/code/ouisync-app/