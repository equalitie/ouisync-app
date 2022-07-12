ARG build_name
ARG build_number
ARG keystore
ARG keystore_password_file
ARG output_destination

FROM cirrusci/flutter:stable as builder

RUN apt-get update
RUN apt-get install -y --no-install-recommends cmake ninja-build clang build-essential pkg-config libgtk-3-dev liblzma-dev lcov libclang-dev gzip

RUN flutter config --enable-linux-desktop

# The flutter SDK in the image is old (2.1x), and we need a recent version for the app packages (3.x), so we delete it and clone the stable channel
RUN rm -r /sdks/flutter
RUN cd /sdks && git clone https://github.com/flutter/flutter.git -b stable --depth 1 --no-single-branch

RUN flutter doctor

RUN cd opt/android-sdk-linux/cmdline-tools/latest/bin/ && sdkmanager --install "ndk;22.0.7026061"
RUN ln -s /usr/bin/python3 /usr/bin/python

#Installing rustup and cargo; adding targets for Android
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH "/root/.cargo/bin:$PATH"

RUN rustup target add aarch64-linux-android
RUN rustup target add armv7-linux-androideabi
RUN rustup target add x86_64-linux-android

#---

RUN mkdir -p /home/code
WORKDIR /home/code/

RUN git clone https://github.com/equalitie/ouisync-app
RUN cd ouisync-app && git submodule update --init --recursive

RUN echo "ndk.dir=/opt/android-sdk-linux/ndk/22.0.7026061" >> /home/code/ouisync-app/android/local.properties
RUN echo "rust.rustcCommand=/root/.cargo/bin/rustc" >> /home/code/ouisync-app/android/local.properties
RUN echo "rust.cargoCommand=/root/.cargo/bin/cargo" >> /home/code/ouisync-app/android/local.properties

RUN cd ouisync-app/ouisync-plugin/ouisync && cargo build --release --lib
RUN cd ouisync-app/ouisync-plugin/ouisync && cargo run --bin bindgen

RUN cd ouisync-app/ouisync-plugin/ && flutter pub get
RUN cd ouisync-app/ouisync-plugin/ && flutter pub run ffigen

RUN cd ouisync-app/ && flutter pub get

RUN cd ouisync-app/ && flutter build apk --release

#---

FROM builder as signer

ARG build_name
ARG build_number
ARG keystore
ARG keystore_password_file
ARG output_destination

WORKDIR /home/code/ouisync-app/util/

COPY ${keystore} .
COPY ${keystore_password_file} .

RUN cd /home/code/ouisync-app && ./util/build-signed-release.sh ${build_name} ${build_number} ./util/${keystore} ./util/${keystore_password_file}


FROM signer as output

ARG output_destination

COPY --from=signer /home/code/ouisync-app/releases ${output_destination}
