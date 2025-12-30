FROM ubuntu:latest

ARG GITHUB_RUNNER_VERSION="2.329.0"
ENV GITHUB_RUNNER_PACKAGE=actions-runner-linux-x64-$GITHUB_RUNNER_VERSION.tar.gz

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        liblttng-ust1 libkrb5-3 zlib1g libssl3t64 libicu74 \
        jq curl \
        docker.io docker-buildx \
        rsync \
        xxd \
        && \
    apt-get clean

ARG USER=runner
RUN useradd -ms /bin/bash $USER
USER $USER
WORKDIR /home/$USER
ENV USER=$USER

ADD --chown=$USER:$USER https://github.com/actions/runner/releases/download/v$GITHUB_RUNNER_VERSION/$GITHUB_RUNNER_PACKAGE .
RUN tar xzf ./$GITHUB_RUNNER_PACKAGE && rm ./$GITHUB_RUNNER_PACKAGE

ADD --chown=$USER:$USER --chmod=a+x entrypoint.sh .
CMD ["./entrypoint.sh"]
