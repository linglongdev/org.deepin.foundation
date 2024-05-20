#!/bin/bash

# Copyright (c) 2022. Uniontech Software Ltd. All rights reserved.
#
# Author:     wurongjie <wurongjie@deepin.org>
#
# Maintainer: wurongjie <wurongjie@deepin.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

model="$1"
arch="$2"

case $model in
    runtime);;
    develop);;
    "") echo "enter an model, like ./create_rootfs.sh runtime amd64" && exit;;
    *) echo "unknow model \"$model\", supported model: runtime, develop" && exit;;
esac


case $arch in
    amd64);;
    arm64);;
    loongarch64);;
    "") echo "enter an architecture, like ./create_rootfs.sh runtime amd64" && exit;;
    *) echo "unknow arch \"$arch\", supported arch: amd64, arm64, loongarch64" && exit;;
esac

# 手动加的软件包写到这里
runtimePackages=(
        libxss1
        dpkg
        ca-certificates
)
# 以下列表来自pkg2appimage的excludedeblist
runtimePackages+=(
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
        # libxcb1 libxcb相关的包放到单独的列表里
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

# 使用tools/check-lib.bash检查出develop包比runtime包多出的lib，这些应该是cmake gcc等开发包带进来的
runtimePackages+=(
libarchive13
libargon2-1
libasan5
libasm1
libatk-bridge2.0-0
libatomic1
libatspi2.0-0
libbabeltrace1
libbinutils
libcairo-gobject2
libcairo-script-interpreter2
libcap2
libcc1-0
libcolord2
libcryptsetup12
libcupsimage2
libcurl4
libdb5.3-stl
libdconf1
libdevmapper-event1.02.1
libdevmapper1.02.1
libdouble-conversion1
libdpkg-perl
libdw1
libepoxy0
libevdev2
libevent-2.1-6
libgdbm-compat4
libgdbm6
libgirepository-1.0-1
libgles1
libgles2
libglib2.0-data
libgmpxx4ldbl
libgnutls-dane0
libgnutls-openssl27
libgnutlsxx28
libgomp1
libgudev-1.0-0
libharfbuzz-gobject0
libharfbuzz-icu0
libidn11
libinput10
libip4tc0
libip6tc0
libipt2
libiptc0
libisl19
libitm1
libjson-c3
libjson-glib-1.0-0
libjson-glib-1.0-common
libjsoncpp1
libkmod2
liblcms2-2
libldap-2.4-2
libldap-common
liblsan0
liblzo2-2
libmpc3
libmpdec2
libmpfr6
libmpx2
libmtdev1
libncurses6
libnghttp2-14
libpcre16-3
libpcre2-16-0
libpcre2-32-0
libpcre2-8-0
libpcre2-posix0
libpcre32-3
libpcrecpp0v5
libperl5.28
libpipeline1
libpopt0
libprocps7
libproxy1v5
libpsl5
libpython-stdlib
libpython2-stdlib
libpython2.7-minimal
libpython2.7-stdlib
libpython3-stdlib
libpython3.7
libpython3.7-minimal
libpython3.7-stdlib
libqt5concurrent5
libqt5core5a
libqt5dbus5
libqt5gui5
libqt5network5
libqt5printsupport5
libqt5sql5
libqt5test5
libqt5widgets5
libqt5xml5
libquadmath0
libreadline7
librhash0
librtmp1
libsasl2-2
libsasl2-modules-db
libsm6
libssh2-1
libtiffxx5
libtsan0
libubsan1
libunbound8
libuv1
libvulkan1
libwacom-common
libwacom2
libwayland-cursor0
libwebpdemux2
libwebpmux3
libxcb-icccm4
libxcb-image0
libxcb-keysyms1
libxcb-render-util0
libxcb-util0
libxkbcommon-x11-0
libxkbcommon0
libxml2-utils
libxtst6
)

# 复制runtimePackage
developPackages=("${runtimePackages[@]}")

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

include=""
case $model in
    runtime)
        include=$(join_by , "${runtimePackages[@]}")
        ;;
    develop)
        include=$(join_by , "${developPackages[@]}")
        ;;
esac

workdir=$(dirname "${BASH_SOURCE[0]}")

mmdebstrap \
        --customize-hook="ARCH=$arch MODEL=$model chroot \$1 /bin/bash < $workdir/hook.sh" \
        --customize-hook="ARCH=$arch MODEL=$model chroot \$1 /bin/bash < hook.sh" \
        --variant=minbase \
        --architectures="$arch" \
        --include="$include" \
        "" "$model.tar" - < "$workdir/sources.list"

rm -r "$model"
mkdir -p "$model/files"
# 不知为何，解压会报错但不影响使用
tar -xvf "$model.tar" -C "$model/files" || true
cp "$workdir/ldconfig/ldconfig_$arch" "$model/files/sbin/"
rm "$model.tar"