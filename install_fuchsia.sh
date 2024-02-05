#!/usr/bin/env bash
# https://fuchsia.dev/fuchsia-src/get-started/get_fuchsia_source

source .env

# NOTE: preflight only works on x64 so we skip it

# run bootstrap script
cd $HOME
curl -s "https://fuchsia.googlesource.com/fuchsia/+/HEAD/scripts/bootstrap?format=TEXT" | base64 --decode | bash

# set up profile with necessary envars
echo "export PATH=$PATH:$HOME/fuchsia/.jiri_root/bin" >> $HOME/.profile
echo "source $HOME/fuchsia/scripts/fx-env.sh" >> $HOME/.profile

source $HOME/.profile

# install IDK
cipd install fuchsia/sdk/core/linux-arm64 latest -root ${IDK_DIR}

# install sysroot
cipd install fuchsia/sysroot/linux-arm64 latest -root ${SYSROOT_DIR}/linux-arm64
cipd install fuchsia/sysroot/linux-amd64 latest -root ${SYSROOT_DIR}/linux-x64
