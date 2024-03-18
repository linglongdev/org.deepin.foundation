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

BASE_REF=org.deepin.foundation

# shellcheck source=/dev/null
#source ./package_list.sh

dpkg -l | grep qemu-user-static > /dev/null || sudo apt-get install -y qemu-user-static
dpkg -l | grep mmdebstrap > /dev/null || sudo apt-get install -y mmdebstrap

sudo rm -rf ${BASE_REF}

runtime_command=sudo mmdebstrap \
	--components=$components \
	--variant=minbase \
	--architectures="$ARCH" \
	--include=elfutils,file,ca-certificates \
	$DISTRO \
	${BASE_REF} \
	$source
sudo find ${BASE_REF} -printf "/runtime/%P\n" > org.deepin.foundation.install

sudo rm -rf ${BASE_REF}

sudo mmdebstrap \
	--components=$components \
	--variant=minbase \
	--architectures="$ARCH" \
	--include=elfutils,file,ca-certificates,binutils,tar,xz-utils,libc6-dev,gcc,g++,cmake \
	$DISTRO \
	${BASE_REF} \
	$source

sudo chown -R "${USER}": ${BASE_REF}

