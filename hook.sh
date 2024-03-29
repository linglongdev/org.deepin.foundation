#!/bin/bash
set -e
# 这个脚本是 mmdebstrap 的hook脚本，需要运行在 mmdebstrap 的 chroot 环境中，请勿手动执行

# 生成缺少的available文件 https://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg1909607.html
/usr/lib/dpkg/methods/apt/update /var/lib/dpkg
# mibase有个多余的uos-license-upgrade，将它和依赖卸载
apt-get -y update
apt-get -y remove uos-license-upgrade
apt-get -y autoremove
# apt生成的配置文件权限是444，会在构建玲珑时因无法复制出错
chmod 644 /etc/apt/apt.conf.d/01autoremove-kernels || true