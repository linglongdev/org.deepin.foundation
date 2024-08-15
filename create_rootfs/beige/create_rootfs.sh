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
    loong64);;
    "") echo "enter an architecture, like ./create_rootfs.sh binary amd64" && exit;;
    *) echo "unknow arch \"$arch\", supported arch: amd64, arm64, loongarch64" && exit;;
esac

binaryPackages=(
acl
at-spi2-common
bash
binutils
binutils-common
binutils-x86-64-linux-gnu
bluez
bluez-obexd
bsdextrautils
bzip2
ca-certificates
coreutils
cryptsetup
cryptsetup-bin
cryptsetup-initramfs
cups
cups-bsd
cups-client
cups-common
cups-core-drivers
cups-daemon
cups-ipp-utils
cups-ppdc
cups-server-common
curl
dbus
dbus-bin
dbus-daemon
dbus-session-bus-common
dbus-system-bus-common
dbus-user-session
dbus-x11
diffutils
dirmngr
e2fsprogs
eject
fdisk
file
findutils
fontconfig
fontconfig-config
fonts-dejavu-core
gawk
gettext-base
gir1.2-atk-1.0
gir1.2-gdkpixbuf-2.0
gir1.2-glib-2.0
gir1.2-harfbuzz-0.0
gir1.2-pango-1.0
glib-networking
glib-networking-common
glib-networking-services
gnupg
gnupg-l10n
gnupg-utils
gnutls-bin
gpg
gpg-agent
gpg-wks-client
gpgconf
gpgsm
gpgv
grep
gzip
hicolor-icon-theme
kbd
kmod
libacl1
libatk1.0-0
libarchive13
libassuan0
libatk-bridge2.0-0
libatspi2.0-0
libattr1
libaudit-common
libaudit1
libbinutils
libblkid1
libbluetooth3
libbz2-1.0
libc-bin
libc-dev-bin
libc-l10n
libc6
libc6-dev
libcap-ng0
libcap2
libcap2-bin
libcbor0.8
libcom-err2
libcrypt-dev
libcrypt1
libcryptsetup12
libctf-nobfd0
libctf0
libcups2
libcupsimage2
libcurl3-gnutls
libcurl4
libdaemon0
libdatrie1
libdbus-1-3
libdecor-0-0
libdrm-common
libdrm-nouveau2
libdrm-radeon1
libdrm2
libdw1
libegl-mesa0
libegl1
libelf1
libepoxy0
libexpat1
libext2fs2
libfdisk1
libffi8
libfido2-1
libfontconfig1
libfreetype6
libfribidi0
libgbm1
libgcrypt20
libgdbm-compat4
libgdbm6
libgdk-pixbuf-2.0-0
libgdk-pixbuf2.0-common
libgl1
libgl1-mesa-dri
libglapi-mesa
libgles2
libglib2.0-0
libglib2.0-bin
libglib2.0-data
libglvnd0
libglx-mesa0
libglx0
libgmp10
libgnutls-dane0
libgnutls30
libgpg-error0
libgprofng0
libgraphite2-3
libharfbuzz-gobject0
libharfbuzz-icu0
libharfbuzz-subset0
libharfbuzz0b
libhogweed6
libice6
libicu74
libidn2-0
libjpeg-turbo-progs
libjpeg62-turbo
libjson-c5
libkmod2
libksba8
liblcms2-2
liblvm2cmd2.03
liblz4-1
liblzma5
libmagic-mgc
libmagic1
libminizip1
libmnl0
libmount1
libncurses6
libncursesw6
libnettle8
libnghttp2-14
libnspr4
libnss-myhostname
libnss3
libp11-kit0
libopengl0
libpam-modules
libpam-modules-bin
libpam-runtime
libpam-systemd
libpam0g
libpango-1.0-0
libpangocairo-1.0-0
libpangoft2-1.0-0
libpangoxft-1.0-0
libpciaccess0
libpcre2-16-0
libpcre2-8-0
libperl5.36
libpipewire-0.3-0
libpipewire-0.3-modules
libpixman-1-0
libpng16-16
libproc2-0
libpsl5
libproxy1v5
libpulse-mainloop-glib0
libpulse0
libpulsedsp
libpython3.12
libpython3.12-minimal
libpython3.12-stdlib
libreadline8
libsframe1
libsharpyuv0
libsasl2-2
libsasl2-modules-db
libseccomp2
libselinux1
libsepol2
libsm6
libsmartcols1
libspa-0.2-bluetooth
libspa-0.2-modules
libsqlite3-0
libss2
libssl3
libsystemd-shared
libsystemd0
libtasn1-6
libthai-data
libthai0
libtiff6
libtinfo6
libtss2-esys-3.0.2-0
libtss2-mu0
libtss2-sys1
libtss2-tcti-cmd0
libtss2-tcti-device0
libtss2-tcti-libtpms0
libtss2-tcti-mssim0
libtss2-tcti-spi-helper0
libtss2-tcti-swtpm0
libtss2-tctildr0
libturbojpeg0
libudev1
libunistring2
libuuid1
libv4l-0
libv4lconvert0
libxcomposite1
libvulkan1
libwayland-client0
libwayland-cursor0
libwayland-egl1
libwayland-server0
libwebp7
libwebpdemux2
libwebpmux3
libwebrtc-audio-processing1
libx11-6
libx11-data
libx11-xcb1
libxau6
libxcb-composite0
libxcb-keysyms1
libxcb-cursor0
libxcb-damage0
libxcb-dri2-0
libxcb-dri3-0
libxcb-ewmh2
libxcb-glx0
libxcb-icccm4
libxcb-image0
libxcb-present0
libxcb-randr0
libxcb-record0
libxcb-render-util0
libxcb-render0
libxcb-res0
libxcb-shape0
libxcb-shm0
libxcb-sync1
libxcb-util1
libxcb-xfixes0
libxcb-xinerama0
libxcb-xinput0
libxcb-xkb1
libxcb-xtest0
libxcb1
libxcursor1
libxdamage1
libxdmcp6
libxext6
libxfixes3
libxft2
libxi6
libxinerama1
libxkbcommon-x11-0
libxkbcommon0
libxkbfile1
libxml2
libxpm4
libxrandr2
libxrender1
libxshmfence1
libxt6
libxtst6
libxv1
libxxf86vm1
libxxhash0
libzstd1
locales
login
logsave
lvm2
mesa-vdpau-drivers
mesa-vulkan-drivers
mount
ncurses-base
ncurses-bin
openssl
p11-kit
p11-kit-modules
passwd
perl
perl-base
perl-modules-5.36
pipewire
pipewire-bin
pipewire-pulse
procps
pulseaudio
pulseaudio-module-bluetooth
pulseaudio-utils
python3.12
python3.12-minimal
readline-common
rfkill
sed
shared-mime-info
sqlite3
systemd
systemd-dev
systemd-sysv
systemd-timesyncd
tar
tzdata
tzdata-legacy
udev
unzip
util-linux
x11-xkb-utils
xdg-user-dirs
xkb-data
xscreensaver-data
xscreensaver-data-extra
xscreensaver-gl
xscreensaver-gl-extra
xz-utils
zlib1g
zstd
)
# 安装输入法
binaryPackages+=(
    fcitx5-frontend-gtk2
    fcitx5-frontend-gtk3
)


developPackages=("${binaryPackages[@]}")

developPackages+=(
elfutils
file
gcc
g++
gdb
cmake
make
automake
xz-utils
patchelf
)


# 将数组拼接成字符串
function join_by {
  local d=${1-} f=${2-}
  if shift 2; then printf %s "$f" "${@/#/$d}"; fi
}

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
        --hook-dir=/usr/share/mmdebstrap/hooks/merged-usr \
        --variant=apt \
        --architectures="$arch" \
        --include="$include" \
        "" "$module.tar" - < "$workdir/sources.list"

# 将tar包解压成目录
rm -rf "$module" || true
mkdir -p "$module/files"
tar -xvf "$module.tar" -C "$module/files" || true # 不知为何，解压到最后会报错但不影响使用
rm "$module.tar"