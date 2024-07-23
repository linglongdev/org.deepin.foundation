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
cp etc/lsb-release /etc/
cp etc/os-version /etc/
cd "$pwd"

# 删除 /etc/localtime，由外部挂载不能是链接
rm /etc/localtime
touch /etc/localtime