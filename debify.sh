#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

if [ ! -d /debs ]
then
    echo "Mount your Debian package directory to /debs."
    exit 1
fi

APTLY_REPO_NAME=debify

aptly repo create \
    -component="$APTLY_COMPONENT" \
    -distribution="$APTLY_DISTRIBUTION" \
    $APTLY_REPO_NAME

aptly repo add $APTLY_REPO_NAME /debs/

aptly repo show $APTLY_REPO_NAME

if [ ! -z "$GPG_PASSPHRASE" ]
then
    passphrase="$GPG_PASSPHRASE"
elif [ ! -z "$GPG_PASSPHRASE_FILE" ]
then
    passphrase=$(<$GPG_PASSPHRASE_FILE)
fi

aptly publish repo \
    -architectures="$APTLY_ARCHITECTURES" \
    -passphrase="$passphrase" \
    $APTLY_REPO_NAME

mv ~/.aptly/public /repo

if [ ! -z "$KEYSERVER" ] && [ ! -z "$URI" ]
then
    release_sig_path=$(find /repo/dists -name Release.gpg | head -1) 
    gpg_key_id=$(gpg --list-packets $release_sig_path | grep -oP "(?<=keyid ).+")

    echo "# setup script for $URI" > /repo/go

    case "$URI" in
        https://*)
            cat >> /repo/go <<-END
if [ ! -e /usr/lib/apt/methods/https ]
then
    apt-get update
    apt-get install -y apt-transport-https
fi
END
    esac

    cat >> /repo/go <<-END
apt-key adv --keyserver $KEYSERVER --recv-keys $gpg_key_id
echo "deb $URI $APTLY_DISTRIBUTION $APTLY_COMPONENT" >> /etc/apt/sources.list

apt-get update
END
fi

tar -C /repo -czf /debs/repo.tar.gz .
