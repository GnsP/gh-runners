# Copyright 2022 Google LLC
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

# Specifying base image as Ubuntu 20.04 LTS
FROM ubuntu:20.04

# Installing necessary tools and packages in non user interactive automated mode
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo LANG=C.UTF-8 > /etc/default/locale && \
    apt-get update && \
    apt-get -y install curl \
    iputils-ping \
    tar \
    jq \
    software-properties-common \
    python \
    python3 \
    python3-pip \
    gcc \
    python3-dev \
    python3-setuptools \
    openjdk-8-jdk-headless \
    gnupg \
    git \
    wget \
    nodejs \
    ruby-dev build-essential \
    rpm \
    maven && \
    gem i fpm -f && \
    update-java-alternatives -s java-1.8.0-openjdk-amd64 && \
    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod a+x /usr/local/bin/yq && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install google-cloud-cli && \
    pip3 install requests yaml-query pyyaml --no-cache-dir -U crcmod

# Specifying GitHub Runner Version
ARG GH_RUNNER_VERSION="2.304.0"
WORKDIR /runner


# Installing GitHub Runner Application on the Docker Image
RUN curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz" && \
    tar -zxf actions.tar.gz && \
    rm -f actions.tar.gz && \
    /runner/bin/installdependencies.sh

COPY entrypoint.sh /runner
RUN chmod +x entrypoint.sh && \
    groupadd -r runner && useradd -r -g runner runner && \
    mkdir /home/runner && \
    chown -R runner:runner /runner && \
    chown -R runner:runner /home/runner
USER runner

# Initiating entrypoint with script for authorising registration of GitHub Runner
ENTRYPOINT ["/runner/entrypoint.sh"]