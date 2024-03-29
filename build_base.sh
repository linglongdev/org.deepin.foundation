#!/bin/bash

# Copyright (c) 2022. Uniontech Software Ltd. All rights reserved.
#
# Author:     Iceyer <me@iceyer.net>
#
# Maintainer: Iceyer <me@iceyer.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

ARCH=$1

case $ARCH in
    amd64);;
    arm64);;
    "") echo "enter an architecture, like ./checkout_base.sh amd64" && exit;;
    *) echo "unknow arch \"$ARCH\", supported arch: amd64, arm64" && exit;;
esac

# shellcheck source=/dev/null
#source ./package_list.sh

dpkg -l | grep qemu-user-static > /dev/null || sudo apt-get install -y qemu-user-static
dpkg -l | grep mmdebstrap > /dev/null || sudo apt-get install -y mmdebstrap

runtimePackages=(
        ca-certificates
)
# 以下列表来自pkg2appimage的excludedeblist
runtimePackages+=(
        apt # 玲珑内部不需要apt
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
        # kde-runtime # kde的东西不需要放到base
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
        # libxcb1 libxcb 放到单独的列表里
        mime-support
        #udev # 玲珑内部应该不需要设备管理
        uuid-runtime
)

runtimePackages+=(
        libice6 # appimage的excludelist有这个包的so文件
        libopengl0 # appimage的excludelist有这个包的so文件
)
# 使用check-dev.bash检查出devel安装了这些包的dev包，为减少构建环境和运行环境差异，runtime也需要安装
runtimePackages+=(
        libsm6
        libxtst6
        libpcre16-3
        libpcre32-3
        libcupsimage2
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


develPackages=("${runtimePackages[@]}")

develPackages+=(
elfutils
file
apt
gcc
g++
gdb
cmake
xz-utils
libicu-dev
)
develPackages+=(
        libice-dev # libice6 的开发包
        libglvnd-dev # libopengl0 的开发包
)
# 通过空链接脚本检查出来的，base中的lib包需要将对应的dev包也安装上
# 否则应用构建时将dev包安装到非标准路径，dev包里面使用相对引用的软链接会无效
develPackages+=(
        libxkbcommon-dev
        libxrandr-dev
        librsvg2-dev
        libmagic-dev
        libp11-kit-dev
        libjpeg62-turbo-dev
        libxxf86vm-dev
        libxcomposite-dev
        libfontconfig1-dev
        libdrm-dev
        libpango1.0-dev
        libtasn1-6-dev
        libatk1.0-dev
        libcups2-dev
        libgtk-3-dev
        libidn2-dev
        libxdmcp-dev
        libgmp-dev
        libpixman-1-dev
        libwayland-dev
        libexpat1-dev
        libasound2-dev
        libpcre3-dev
        libxft-dev
        libcairo2-dev
        libxcursor-dev
        libxinerama-dev
        libfreetype6-dev
        libglib2.0-dev
        libxext-dev
        libgdk-pixbuf2.0-dev
        libxfixes-dev
        libgbm-dev
        libx11-xcb-dev
        libtiff-dev
        libxdamage-dev
        libpng-dev
        libepoxy-dev
        libfribidi-dev
        libgraphite2-dev
        libjbig-dev
        libxshmfence-dev
        libglu1-mesa-dev
        libssl-dev
        libharfbuzz-dev
        libxau-dev
        libatk-bridge2.0-dev
        libffi-dev
        libxi-dev
        libx11-dev
        libxrender-dev
        libatspi2.0-dev
        nettle-dev
        libudev-dev
        libsqlite3-dev
        libgnutls28-dev
        libproxy-dev
)

# libxcb的附加包里面有 include "xcb.h"，所以需要把所有包都放进去
develPackages+=(
        libxcb1-dev
        libxcb-composite0-dev
        libxcb-damage0-dev
        libxcb-dpms0-dev
        libxcb-glx0-dev
        libxcb-randr0-dev
        libxcb-record0-dev
        libxcb-render0-dev
        libxcb-res0-dev
        libxcb-screensaver0-dev
        libxcb-shape0-dev
        libxcb-shm0-dev
        libxcb-sync-dev
        libxcb-xf86dri0-dev
        libxcb-xfixes0-dev
        libxcb-xinerama0-dev
        libxcb-xinput-dev
        libxcb-xtest0-dev
        libxcb-xv0-dev
        libxcb-xvmc0-dev
        libxcb-dri2-0-dev
        libxcb-present-dev
        libxcb-dri3-dev
        libxcb-xkb-dev
)

# 将数组拼接成字符串
function join_by {
  local d=${1-} f=${2-}
  if shift 2; then printf %s "$f" "${@/#/$d}"; fi
}

# 设置rootfs目录名
rootfs="rootfs"
# 清理目录
sudo rm -rf "$rootfs"
# 创建base环境
sudo mmdebstrap \
        --customize-hook="chroot $rootfs /bin/bash < hook.sh" \
        --components="main,contrib,non-free" \
        --variant=minbase \
        --architectures="$ARCH" \
        --include=$(join_by , "${runtimePackages[@]}") \
        eagle \
        "$rootfs" \
        http://pools.uniontech.com/desktop-professional

# 生成base环境的包列表，无实际作用，仅供参考
grep "^Package:" "$rootfs/var/lib/dpkg/status" | awk '{print $2}' > runtime.packages.list

# 生成base环境的文件列表，文件列表会被玲珑用于拆分runtime和devel包
sudo find "$rootfs" \
        -not -path "$rootfs/usr/share/doc/*" \
        -not -path "$rootfs/usr/share/man/*" \
        -not -path "$rootfs/usr/share/icons/*" \
        -printf "/runtime/%P\n" > org.deepin.foundation.install
# 清理目录
sudo rm -rf "$rootfs"
# 创建带构建的base环境
sudo mmdebstrap \
        --customize-hook="chroot $rootfs /bin/bash < hook.sh" \
        --components="main,contrib,non-free" \
        --variant=minbase \
        --architectures="$ARCH" \
        --include=$(join_by , "${develPackages[@]}") \
        eagle \
        "$rootfs" \
        http://pools.uniontech.com/desktop-professional

# 生成带构建的base环境的包列表，无实际作用，仅供参考
grep "^Package:" "$rootfs/var/lib/dpkg/status" | awk '{print $2}' > devel.packages.list

# 更改rootfs的文件权限，为构建玲珑包做准备
sudo chown -R "${USER}": "$rootfs"
