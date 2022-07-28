#!/bin/bash
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

# Formatting URL for GitHub API for creation of registration token for an organization
registration_url="https://api.github.com/orgs/${ORG_NAME}/actions/runners/registration-token"
echo "Requesting registration URL at '${registration_url}'"

# Making POST Request to GitHub API along with token header using curl
payload=$(curl -sX POST -H "Authorization: token ${GITHUB_TOKEN}" ${registration_url})
export RUNNER_TOKEN=$(echo $payload | jq .token --raw-output)

mkdir -p ~/.m2
ln -s /etc/maven-settings/settings.xml ~/.m2/settings.xml
# Initialize gnupg
gpg --batch --allow-secret-key-import --import /etc/gnupg/private.key
gpg --batch --import-ownertrust /etc/gnupg/ownertrust.txt
# configure runner
export RUNNER_ALLOW_RUNASROOT=1
export LANG=C.UTF-8
# Creating an configuring self hosted runner
/runner/config.sh --name $(hostname) --token ${RUNNER_TOKEN} --url https://github.com/${ORG_NAME} --work ${RUNNER_WORKDIR} --unattended --replace --ephemeral --labels ${RUNNER_LABEL}

remove() {
	    /runner/config.sh remove --unattended --token "${RUNNER_TOKEN}"
    }

# Error handled exits
trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

/runner/bin/runsvc.sh "$@" &

wait $!
