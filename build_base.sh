#!/bin/bash

# Copyright (c) 2022. Uniontech Software Ltd. All rights reserved.
#
# Author:     Iceyer <me@iceyer.net>
#
# Maintainer: Iceyer <me@iceyer.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e
set -x

DISTRO=$1
ARCH=$2


if [ -s "$DISTRO" ]; then
    echo "enter an distro, like ./build_base.sh beige amd64" 
    exit
elif [ ! -e "create_rootfs/$DISTRO" ]; then
    echo "unknow distro \"$DISTRO\", supported distro: `ls create_rootfs|tr '\n' ','`"
    exit
fi

case $ARCH in
    amd64)
        LINGLONG_ARCH="x86_64"
        TRIPLET_LIST="x86_64-linux-gnu"
        ;;
    arm64)
        LINGLONG_ARCH="arm64"
        TRIPLET_LIST="aarch64-linux-gnu"
        ;;
    loongarch64)
        LINGLONG_ARCH="loongarch64"
        TRIPLET_LIST="loongarch64-linux-gnu"
        ;;
    loong64)
        LINGLONG_ARCH="loong64"
        TRIPLET_LIST="loongarch64-linux-gnu"
        ;;
    "") echo "enter an architecture, like ./build_base.sh beige amd64" && exit;;
    *) echo "unknow arch \"$ARCH\", supported arch: amd64, arm64, loongarch64, loong64" && exit;;
esac

# shellcheck source=/dev/null
#source ./package_list.sh

# install depends
dpkg -l | grep mmdebstrap > /dev/null || sudo apt-get install -y mmdebstrap
dpkg -l | grep tmux > /dev/null || sudo apt-get install -y tmux
dpkg -l | grep linglong-builder > /dev/null || sudo apt-get install -y linglong-builder

# init ostree repo
ll-builder -h > /dev/null

# shellcheck source=/dev/null
source "./create_rootfs/$DISTRO/version.sh"
export CHANNEL="main"
export LINGLONG_ARCH

for module in develop binary; do
        echo $module
        # 生成rootfs
        "./create_rootfs/$DISTRO/create_rootfs.sh" $module "$ARCH"
        # 复制patch_rootfs目录
        cp -rP patch_rootfs/* "$module/files/"
        # 生成 linglong-triplet-list
        echo "$TRIPLET_LIST" > "$module/files/etc/linglong-triplet-list"
        # 生成install
        find "$module/files" > "$module/$APPID.install"
        # 生成info.json
        MODULE=$module envsubst < info.template.json > "$module/info.json"
        # 生成linglong.yaml
        envsubst < linglong.template.yaml > "linglong.yaml"
        # 生成packages.list，并复制到多个位置
        grep "^Package:" "$module/files/var/lib/dpkg/status" | awk '{print $2}' > "$module.packages.list"
        cp $module.packages.list "./create_rootfs/$DISTRO/$LINGLONG_ARCH.$module.packages.list"
        cp $module.packages.list "$module/files/packages.list"

        # 提交到ostree
        ostree commit --repo="$HOME/.cache/linglong-builder/repo" -b "$CHANNEL/$APPID/$VERSION/$LINGLONG_ARCH/$module" $module
        # checkout到layers目录
        rm -rf "$HOME/.cache/linglong-builder/layers/main/$APPID/$VERSION/$LINGLONG_ARCH/$module" || true
        mkdir -p "$HOME/.cache/linglong-builder/layers/main/$APPID/$VERSION/$LINGLONG_ARCH" || true
        ostree --repo="$HOME/.cache/linglong-builder/repo" checkout "$CHANNEL/$APPID/$VERSION/$LINGLONG_ARCH/$module" "$HOME/.cache/linglong-builder/layers/main/$APPID/$VERSION/$LINGLONG_ARCH/$module"
done

envsubst < linglong.template.yaml > "linglong.yaml"
