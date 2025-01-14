#!/bin/bash
set -e
# 这个脚本是 mmdebstrap 的hook脚本，需要运行在 mmdebstrap 的 chroot 环境中，请勿手动执行

# 生成缺少的available文件，使apt/dpkg能正常工作
echo "" > /var/lib/dpkg/available
apt-get -y update

# 提取deepin-desktop-base包里面的lsb-release和os-version文件
pwd=$PWD
cd $(mktemp -d)
apt-get download deepin-desktop-base
dpkg-deb -R ./*.deb ./
cp usr/share/deepin-desktop-base/lsb-release /etc/
cp usr/share/deepin-desktop-base/os-version /etc/
cd "$pwd"

# mibase有个多余的uos-license-upgrade，将它和依赖卸载
apt-get -y remove uos-license-upgrade --purge || true
apt-get -y autoremove --purge

# apt生成的配置文件权限是444，会在构建玲珑时因无法复制出错
chmod 644 /etc/apt/apt.conf.d/01autoremove-kernels