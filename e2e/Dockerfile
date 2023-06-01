# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo LANG=C.UTF-8 > /etc/default/locale && \
    apt-get update && \
    apt-get -y install curl \
    iputils-ping \
    tar \
    jq \
    python \
    python3 \
    python3-pip \
    openjdk-8-jdk-headless \
    gnupg \
    git \
    npm \
    maven && \
    npm i -g n && \
    n 16.20.0 && \
    update-java-alternatives --jre-headless -s java-1.8.0-openjdk-amd64 && \
    pip3 install requests yaml-query pyyaml && \
    curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    -o google-chrome-stable_current_amd64.deb && \
    apt -y install ./google-chrome-stable_current_amd64.deb
    
ARG GH_RUNNER_VERSION="2.304.0"
WORKDIR /runner
RUN curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz" && \
    tar -zxf actions.tar.gz && \
    rm -f actions.tar.gz && \
    ./bin/installdependencies.sh

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh && \
    groupadd -r runner && useradd -r -g runner runner && \
    mkdir /home/runner && \
    chown -R runner:runner /runner && \
    chown -R runner:runner /home/runner
USER runner
ENTRYPOINT ["/runner/entrypoint.sh"]
