#!/bin/bash
set -e
set -x

# workspace设置成tmpfs, 制作速度会快很多
workdir=$(mktemp -d)
mkosi --force --workspace-dir="$workdir"

# mkosi使用subuid，为避免权限问题，先制作tar格式的rootfs再解压
rm -rf output/files || true
mkdir output/files
tar -xf output/image -C output/files
rm -rf output/image*

# 获取当前架构信息并保存到rootfs/etc/linglong-triplet-list文件中
LINGLONG_ARCH=$(dpkg-architecture -q DEB_BUILD_GNU_CPU)
export LINGLONG_ARCH

echo "$LINGLONG_ARCH" >"output/files/etc/linglong-triplet-list"

# 清理仓库中已存在的base
# shellcheck source=/dev/null
source version.bash
ll-builder list | grep "$APPID/$VERSION" | xargs ll-builder remove

# 生成linglong.yaml和info.json文件
envsubst <templates/linglong.template.yaml >"output/linglong.yaml"
MODULE=binary envsubst <templates/info.template.json >"output/info.json"
ll-builder import-dir ./output
MODULE=develop envsubst <templates/info.template.json >"output/info.json"
ll-builder import-dir ./output
