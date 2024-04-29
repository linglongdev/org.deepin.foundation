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
    "") echo "enter an architecture, like ./build_base.sh beige amd64" && exit;;
    *) echo "unknow arch \"$ARCH\", supported arch: amd64, arm64, loongarch64" && exit;;
esac

# shellcheck source=/dev/null
#source ./package_list.sh

dpkg -l | grep mmdebstrap > /dev/null || sudo apt-get install -y mmdebstrap
dpkg -l | grep tmux > /dev/null || sudo apt-get install -y tmux

# shellcheck source=/dev/null
source "./create_rootfs/$DISTRO/version.sh"
CHANNEL="main"

# 生成rootfs
sudo tmux new-session -d -s "create rootfs"
sudo tmux send-keys "./create_rootfs/$DISTRO/create_rootfs.sh develop $ARCH && echo create develop rootfs success && exit" Enter
sudo tmux split-window -v -t "create rootfs"
sudo tmux send-keys "./create_rootfs/$DISTRO/create_rootfs.sh runtime $ARCH && echo create runtime rootfs success && exit" Enter
sudo tmux attach-session

rootfs=runtime/files
# 删除runtime的文档内容
sudo rm -rf "$rootfs/usr/share/doc/" "$rootfs/usr/share/man/" "$rootfs/usr/share/icons/"

for model in runtime develop; do
        echo $model
        # 更改文件权限
        sudo chown -R "${USER}": $model
        # 清理dev
        sudo rm -rf "$model/files/dev" || true
        mkdir "$model/files/dev"
        # 生成install
        sudo find "runtime/files" > $model/org.deepin.foundation.install
        # 生成info.json
        MODULE=$model LINGLONG_ARCH=$LINGLONG_ARCH envsubst < info.template.json > "$model/info.json"
        # 生成linglong.yaml
        envsubst < linglong.template.yaml > "$model/linglong.yaml"
        # 生成package.list
        grep "^Package:" "$model/files/var/lib/dpkg/status" | awk '{print $2}' > "./create_rootfs/$DISTRO/$LINGLONG_ARCH.$model.packages.list"
        # 复制 profile.d目录
        cp -rP patch_rootfs/* "$model/files/"
        # 生成 linglong-triplet-list
        echo "$TRIPLET_LIST" > "$model/files/etc/linglong-triplet-list"
        # 提交到ostree
        ostree commit --repo="$HOME/.cache/linglong-builder/repo" -b "$CHANNEL/org.deepin.foundation/$VERSION/$LINGLONG_ARCH/$model" $model
        # checkout到layers目录
        rm -rf "$HOME/.cache/linglong-builder/layers/main/org.deepin.foundation/$VERSION/$LINGLONG_ARCH/$model" || true
        mkdir -p "$HOME/.cache/linglong-builder/layers/main/org.deepin.foundation/$VERSION/$LINGLONG_ARCH" || true
        ostree --repo="$HOME/.cache/linglong-builder/repo" checkout "$CHANNEL/org.deepin.foundation/$VERSION/$LINGLONG_ARCH/$model" "$HOME/.cache/linglong-builder/layers/main/org.deepin.foundation/$VERSION/$LINGLONG_ARCH/$model"
done

envsubst < linglong.template.yaml > "linglong.yaml"
