#!/bin/bash

# Copyright (c) 2022. Uniontech Software Ltd. All rights reserved.
#
# Author:     Iceyer <me@iceyer.net>
#
# Maintainer: Iceyer <me@iceyer.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

DISTRO=$1
ARCH=$2

case $DISTRO in
    apricot)
		case $ARCH in
			amd64);;
			"") echo "enter an architecture, like ./checkout_base.sh apricot amd64" && exit;;
			*) echo "unknow arch \"$ARCH\", supported arch: amd64" && exit;;
		esac
		components="main,contrib,non-free"
		source="https://community-packages.deepin.com/deepin/apricot/"
		;;
    beige)
		case $ARCH in
			amd64);;
			arm64);;
			"") echo "enter an architecture, like ./checkout_base.sh beige amd64" && exit;;
			*) echo "unknow arch \"$ARCH\", supported arch: amd64, arm64" && exit;;
		esac
		components="main,commercial,community"
		source="https://community-packages.deepin.com/beige/"
		;;
    "") echo "enter an distro, like ./checkout_base.sh beige amd64" && exit;;
    *) echo "unknow arch \"$DISTRO\", supported distro: apricot, beige" && exit;;
esac

# shellcheck source=/dev/null
#source ./package_list.sh

dpkg -l | grep qemu-user-static > /dev/null || sudo apt-get install -y qemu-user-static
dpkg -l | grep mmdebstrap > /dev/null || sudo apt-get install -y mmdebstrap


export VERSION="20.0.0.10"
export CHANNEL="main"

# 生成rootfs
sudo tmux new-session -d -s "create rootfs"
sudo tmux send-keys "./create_rootfs.sh devel $ARCH $VERSION; echo create devel rootfs success" Enter
sudo tmux split-window -v -t "create rootfs"
sudo tmux send-keys "./create_rootfs.sh runtime $ARCH $VERSION; echo create runtime rootfs success" Enter
sudo tmux attach-session

rootfs=runtime/files
# 删除runtime的文档内容
sudo rm -rf "$rootfs/usr/share/doc/*" "$rootfs/usr/share/man/*" "$rootfs/usr/share/icons/*"


for model in runtime devel; do
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
        ostree commit --repo "$HOME/.cache/linglong-builder/repo" -b $CHANNEL/org.deepin.foundation/$VERSION/x86_64/$model $model
done

envsubst < linglong.template.yaml > "linglong.yaml"