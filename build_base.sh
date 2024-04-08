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
ARCH=$1
LINGLONG_ARCH=""
case $ARCH in
    amd64)
        LINGLONG_ARCH="x86_64"
        ;;
    arm64)
        LINGLONG_ARCH="arm64"
        ;;
    loongarch64)
        LINGLONG_ARCH="loongarch64"
        ;;
    "") echo "enter an architecture, like ./checkout_base.sh amd64" && exit;;
    *) echo "unknow arch \"$ARCH\", supported arch: amd64, arm64, loongarch64" && exit;;
esac

# shellcheck source=/dev/null
#source ./package_list.sh

dpkg -l | grep mmdebstrap > /dev/null || sudo apt-get install -y mmdebstrap
dpkg -l | grep tmux > /dev/null || sudo apt-get install -y tmux

export VERSION="20.0.0.11"
export CHANNEL="main"

# 生成rootfs
sudo tmux new-session -d -s "create rootfs"
sudo tmux send-keys "./create_rootfs.sh develop $ARCH $VERSION && echo create develop rootfs success && exit" Enter
sudo tmux split-window -v -t "create rootfs"
sudo tmux send-keys "./create_rootfs.sh runtime $ARCH $VERSION && echo create runtime rootfs success && exit" Enter
sudo tmux attach-session

rootfs=runtime/files
# 删除runtime的文档内容
sudo rm -rf "$rootfs/usr/share/doc/*" "$rootfs/usr/share/man/*" "$rootfs/usr/share/icons/*"


for model in runtime develop; do
        echo $model
        sudo chown -R "${USER}": $model
        # 清理dev
        sudo rm -rf "$model/files/dev" || true
        mkdir "$model/files/dev"
        # 生成install
        sudo find "runtime/files" > $model/org.deepin.foundation.install
        # 生成info.json
        MODULE=$model envsubst < info.template.json > "$model/info.json"
        # 生成linglong.yaml
        envsubst < linglong.template.yaml > "$model/linglong.yaml"
        # 生成package.list
        grep "^Package:" "$model/files/var/lib/dpkg/status" | awk '{print $2}' > "$model.packages.list"
        # 提交到ostree
        ostree commit --repo="$HOME/.cache/linglong-builder/repo" -b "$CHANNEL/org.deepin.foundation/$VERSION/$LINGLONG_ARCH/$model" $model
        rm -rf "$HOME/.cache/linglong-builder/layers/main/org.deepin.foundation/$VERSION/$LINGLONG_ARCH/$model" || true
        mkdir -p "$HOME/.cache/linglong-builder/layers/main/org.deepin.foundation/$VERSION/$LINGLONG_ARCH" || true
        ostree --repo="$HOME/.cache/linglong-builder/repo" checkout "$CHANNEL/org.deepin.foundation/$VERSION/$LINGLONG_ARCH/$model" "$HOME/.cache/linglong-builder/layers/main/org.deepin.foundation/$VERSION/$LINGLONG_ARCH/$model"
done

envsubst < linglong.template.yaml > "linglong.yaml"
