#!/bin/bash
set -e
set -x

rm -rf output || true

mkosi --force --output=image_binary
mkosi --force --output=image_develop -p elfutils,file,gcc,g++,gdb,gdbserver,cmake,make,automake,patchelf

# 获取当前架构信息并保存到rootfs/etc/linglong-triplet-list文件中
LINGLONG_ARCH=$(dpkg-architecture -q DEB_BUILD_GNU_TYPE)
export LINGLONG_ARCH
# 清理仓库中已存在的base
# shellcheck source=/dev/null
source version.bash
ll-builder list | grep "$APPID/$VERSION" | xargs ll-builder remove

for module in binary develop; do
    # mkosi使用subuid，为避免权限问题，先制作tar格式的rootfs，在手动解压
    mkdir -p output/$module/files
    tar -xf output/image_$module -C output/$module/files
    echo "$LINGLONG_ARCH" >"output/$module/files/etc/linglong-triplet-list"
    envsubst <templates/linglong.template.yaml >"output/$module/linglong.yaml"
    MODULE=$module envsubst <templates/info.template.json >"output/$module/info.json"
done

ll-builder import-dir output/binary
ll-builder import-dir output/develop
