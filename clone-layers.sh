#!/usr/bin/env bash

set -e

workspace_dir="workspace"
layers_dir="sources"

# TODO set to the Yocto release you want to use, e.g. thud or warrior
yocto_release="thud"

mkdir -p "${workspace_dir}/${layers_dir}" && cd "${workspace_dir}"

repo init -u https://github.com/Freescale/fsl-community-bsp-platform -b ${yocto_release}
repo sync