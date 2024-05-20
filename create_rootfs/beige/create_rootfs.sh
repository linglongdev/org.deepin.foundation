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


rm -r "$model" || true
mkdir "$model"
rootfs="$model/files"

runtimePackages=(
        libxss1
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

# 使用tools/check-lib.bash检查出develop包比runtime包多出的lib，这些应该是cmake gcc等开发包带进来的
# runtimePackages+=(
#         libarchive13
#         libargon2-1
#         libasan8
#         libasm1
#         libatk-bridge2.0-0
#         libatomic1
#         libatspi2.0-0
#         libbabeltrace1
#         libbinutils
#         libboost-regex1.83.0
#         libcairo-gobject2
#         libcairo-script-interpreter2
#         libcc1-0
#         libclang-cpp17
#         libcolord2
#         libcryptsetup12
#         libctf-nobfd0
#         libctf0
#         libcupsimage2
#         libcurl3-gnutls
#         libcurl4
#         libdb5.3-stl
#         libdconf1
#         libdebuginfod-common
#         libdebuginfod1
#         libdevmapper-event1.02.1
#         libdevmapper1.02.1
#         libdpkg-perl
#         libdw1
#         libegl-mesa0
#         libegl1
#         libepoxy0
#         libevent-2.1-7
#         libfdisk1
#         libgles1
#         libgles2
#         libglib2.0-data
#         libgmpxx4ldbl
#         libgnutls-dane0
#         libgnutls-openssl27
#         libgnutlsxx30
#         libgomp1
#         libgprofng0
#         libharfbuzz-cairo0
#         libharfbuzz-gobject0
#         libharfbuzz-icu0
#         libharfbuzz-subset0
#         libhwasan0
#         libipt2
#         libisl23
#         libitm1
#         libjansson4
#         libjson-c5
#         libjsoncpp25
#         libkmod2
#         liblcms2-2
#         libldap-2.5-0
#         liblsan0
#         liblzo2-2
#         libmagic-mgc
#         libmagic1
#         libmpc3
#         libmpfr6
#         libncurses6
#         libncursesw6
#         libnghttp2-14
#         libpcre2-16-0
#         libpcre2-32-0
#         libpcre2-posix3
#         libpfm4
#         libpkgconf3
#         libproc2-0
#         libproxy1v5
#         libpsl5
#         libpython3-stdlib
#         libpython3.11
#         libpython3.11-minimal
#         libpython3.11-stdlib
#         libquadmath0
#         libreadline8
#         librhash0
#         librtmp1
#         libsasl2-2
#         libsasl2-modules-db
#         libsframe1
#         libsm6
#         libsource-highlight-common
#         libsource-highlight4v5
#         libssh2-1
#         libtiffxx6
#         libtsan2
#         libubsan1
#         libunbound8
#         libuv1
#         libwebpdecoder3
#         libwebpdemux2
#         libwebpmux3
#         libxkbcommon0
#         libxml2-utils
#         libxtst6
#         libyaml-0-2
# )

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
export ARCH=$arch
export MODEL=$model
mmdebstrap \
        --customize-hook="chroot $rootfs /bin/bash < $workdir/hook.sh" \
        --hook-dir=/usr/share/mmdebstrap/hooks/merged-usr \
        --components="main" \
        --variant=minbase \
        --architectures="$arch" \
        --include="$include" \
        beige \
        "$rootfs" \
        https://pools.uniontech.com/deepin-beige
