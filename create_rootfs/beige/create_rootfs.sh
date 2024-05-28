#!/bin/bash

# Copyright (c) 2022. Uniontech Software Ltd. All rights reserved.
#
# Author:     wurongjie <wurongjie@deepin.org>
#
# Maintainer: wurongjie <wurongjie@deepin.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

module="$1"
arch="$2"

case $module in
    runtime);;
    develop);;
    "") echo "enter an module, like ./create_rootfs.sh runtime amd64" && exit;;
    *) echo "unknow module \"$module\", supported module: runtime, develop" && exit;;
esac


case $arch in
    amd64);;
    arm64);;
    loongarch64);;
    "") echo "enter an architecture, like ./create_rootfs.sh runtime amd64" && exit;;
    *) echo "unknow arch \"$arch\", supported arch: amd64, arm64, loongarch64" && exit;;
esac

runtimePackages=(
        libxss1
        libicu74
        ca-certificates
        deepin-keyring
)
# 以下列表来自pkg2appimage的excludedeblist
runtimePackages+=(
        apt # 调试用
        # apt-transport-https # 不需要这个插件了
        # dbus # 已经存在mibase
        # dictionaries-common # 这个在容器中用不到
        fontconfig
        fontconfig-config
        # gvfs-backends 这个好像没用，会带一大堆依赖
        # gksu # 仓库没有这个包
        glib-networking
        # gstreamer1.0-plugins-base # 不需要gstreamer
        # gstreamer1.0-plugins-good # 不需要gstreamer
        # gstreamer1.0-plugins-ugly # 不需要gstreamer
        # gstreamer1.0-pulseaudio # 不需要gstreamer
        # gtk2-engines-pixbuf # # gtk的东西不需要放到base
        # kde-runtime # kde的东西不需要放到base
        libasound2
        libatk1.0-0
        libc6-dev
        libcairo2
        libcups2
        libdbus-1-3
        libdrm2
        # libegl1-mesa # v23没有这个包
        libfontconfig1
        libgbm1
        libgdk-pixbuf2.0-0
        libgl1
        # libgl1-mesa # 仓库没有这个包
        libgl1-mesa-dri
        # libgl1-mesa-glx # 仓库没有这个包
        libglu1-mesa
        libgtk2.0-0
        libgtk-3-0
        libnss3
        libpango1.0-0
        libpango-1.0-0
        libpangocairo-1.0-0
        libpangoft2-1.0-0
        libtasn1-6
        libwayland-dev
        # libxcb1 libxcb 放到单独的列表里
        mime-support
        #udev # 玲珑内部应该不需要设备管理
        uuid-runtime
)

# appimage的excludelist有这些包的so文件
runtimePackages+=(
        libice6
        libopengl0
)

# libxcb的附加包里面有 include "xcb.h"，所以需要把libxcb所有包都放进去
runtimePackages+=(
        libxcb1
        libxcb-doc
        libxcb-composite0
        libxcb-damage0
        libxcb-dpms0
        libxcb-glx0
        libxcb-randr0
        libxcb-record0
        libxcb-render0
        libxcb-res0
        libxcb-screensaver0
        libxcb-shape0
        libxcb-shm0
        libxcb-sync1
        libxcb-xf86dri0
        libxcb-xfixes0
        libxcb-xinerama0
        libxcb-xinput0
        libxcb-xtest0
        libxcb-xv0
        libxcb-xvmc0
        libxcb-dri2-0
        libxcb-present0
        libxcb-dri3-0
        libxcb-xkb1
)

developPackages=("${runtimePackages[@]}")

developPackages+=(
        elfutils
        file
        gcc
        g++
        gdb
        cmake
        xz-utils
        patchelf
)

# 将develop中的lib库添加到runtime，减少两者的差异，避免在develop构建好应用后，无法在runtime运行的问题
while IFS= read -r line; do
    runtimePackages+=("$line")
done < <(grep "^lib" develop.packages.list | grep -v dev$ | grep -v bin$)

# 将数组拼接成字符串
function join_by {
  local d=${1-} f=${2-}
  if shift 2; then printf %s "$f" "${@/#/$d}"; fi
}

include=""
case $module in
    runtime)
        include=$(join_by , "${runtimePackages[@]}")
        ;;
    develop)
        include=$(join_by , "${developPackages[@]}")
        ;;
esac

# shellcheck disable=SC2001
echo "$include"|sed 's|,|\n|g' > "$module.include.list"


workdir=$(dirname "${BASH_SOURCE[0]}")

mmdebstrap \
        --customize-hook="ARCH=$arch MODULE=$module chroot \$1 /bin/bash < $workdir/hook.sh" \
        --customize-hook="ARCH=$arch MODULE=$module chroot \$1 /bin/bash < hook.sh" \
        --hook-dir=/usr/share/mmdebstrap/hooks/merged-usr \
        --components="main" \
        --variant=minbase \
        --architectures="$arch" \
        --include="$include" \
        beige \
        "$module.tar" \
        https://pools.uniontech.com/deepin-beige

# 将tar包解压成目录
rm -rf "$module" || true
mkdir -p "$module/files"
tar -xvf "$module.tar" -C "$module/files" || true # 不知为何，解压到最后会报错但不影响使用
rm "$module.tar"