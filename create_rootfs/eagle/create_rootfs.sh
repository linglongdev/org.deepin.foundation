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
    binary);;
    develop);;
    "") echo "enter an module, like ./create_rootfs.sh binary amd64" && exit;;
    *) echo "unknow module \"$module\", supported module: binary, develop" && exit;;
esac


case $arch in
    amd64);;
    arm64);;
    loongarch64);;
    "") echo "enter an architecture, like ./create_rootfs.sh binary amd64" && exit;;
    *) echo "unknow arch \"$arch\", supported arch: amd64, arm64, loongarch64" && exit;;
esac

# 手动加的软件包写到这里
binaryPackages=(
        libxss1
        dpkg
        ca-certificates
)
# 以下列表来自pkg2appimage的excludedeblist
binaryPackages+=(
        apt # 调试用
        # apt-transport-https
        # dbus # 已经存在mibase
        # dictionaries-common # 这个在容器中用不到
        fontconfig
        fontconfig-config
        # gvfs-backends 这个好像没用，会带一大堆依赖
        # gksu # 仓库没有这个包
        glib-networking
        # gstreamer1.0-plugins-base
        # gstreamer1.0-plugins-good
        # gstreamer1.0-plugins-ugly
        # gstreamer1.0-pulseaudio
        # gtk2-engines-pixbuf # # gtk的东西不需要放到base
        # kde-binary # kde的东西不需要放到base
        libasound2
        libatk1.0-0
        libc6-dev
        libcairo2
        libcups2
        libdbus-1-3
        libdrm2
        libegl1-mesa
        libfontconfig1
        libgbm1
        libgdk-pixbuf2.0-0
        libgl1
        # libgl1-mesa # 仓库没有这个包
        # libgl1-mesa-dri # 仓库没有这个包
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
        libwayland-egl1-mesa
        # libxcb1 libxcb相关的包放到单独的列表里
        mime-support
        #udev # 玲珑内部应该不需要设备管理
        uuid-binary
)

# appimage的excludelist有这些包的so文件
binaryPackages+=(
        libice6
        libopengl0
)

# libxcb的附加包里面有 include "xcb.h"，所以需要把libxcb所有包都放进去
binaryPackages+=(
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

# 复制binaryPackage
developPackages=("${binaryPackages[@]}")

# 构建需要的软件包
developPackages+=(
        dpkg
        elfutils
        file
        apt
        gcc
        g++
        gdb
        cmake
        xz-utils
        patchelf
)

# 将数组拼接成字符串
function join_by {
  local d=${1-} f=${2-}
  if shift 2; then printf %s "$f" "${@/#/$d}"; fi
}


# 将develop中的lib库添加到binary，减少两者的差异，避免在develop构建好应用后，无法在binary运行的问题
while IFS= read -r line; do
    binaryPackages+=("$line")
done < <(grep "^lib" develop.packages.list | grep -v dev$ | grep -v bin$)

include=""
case $module in
    binary)
        include=$(join_by , "${binaryPackages[@]}")
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
        --variant=minbase \
        --architectures="$arch" \
        --include="$include" \
        "" "$module.tar" - < "$workdir/sources.list"

# 将tar包解压成目录
rm -rf "$module" || true
mkdir -p "$module/files"
tar -xvf "$module.tar" -C "$module/files" || true # 不知为何，解压到最后会报错但不影响使用
cp "$workdir/ldconfig/ldconfig_$arch" "$module/files/sbin/"
rm "$module.tar"