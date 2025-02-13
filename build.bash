#!/bin/bash
set -e
set -x

ARCH=$1

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
loong64)
    LINGLONG_ARCH="loong64"
    TRIPLET_LIST="loongarch64-linux-gnu"
    ;;
sw64)
    LINGLONG_ARCH="sw64"
    TRIPLET_LIST="sw_64-linux-gnu"
    ;;
"") echo "enter an architecture, like ./build_base.sh amd64" && exit ;;
*) echo "unknow arch \"$ARCH\", supported arch: amd64, arm64, loongarch64, loong64" && exit ;;
esac

export LINGLONG_ARCH

rm -rf output || true

mkosi --force --output=image_binary
mkosi --force --output=image_develop -p elfutils,file,gcc,g++,gdb,gdbserver,cmake,make,automake,patchelf

# 清理仓库中已存在的base
# shellcheck source=/dev/null
source version.bash
ll-builder list | grep "$APPID/$VERSION" | xargs ll-builder remove

for module in binary develop; do
    # mkosi使用subuid，为避免权限问题，先制作tar格式的rootfs，在手动解压
    mkdir -p output/$module/files
    tar -xf output/image_$module -C output/$module/files
    echo "$TRIPLET_LIST" >"output/$module/files/etc/linglong-triplet-list"
    envsubst <templates/linglong.template.yaml >"output/$module/linglong.yaml"
    MODULE=$module envsubst <templates/info.template.json >"output/$module/info.json"
done

ll-builder import-dir output/binary
ll-builder import-dir output/develop
