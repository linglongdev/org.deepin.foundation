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
cd usr/share/deepin-desktop-base
cp lsb-release /etc/
cp os-version /etc/
cd "$pwd"
# 玲珑中不需要使用mount
apt-get -y --allow-remove-essential remove mount --purge
# 删除runtime的文档内容
if [[ "$MODEL" == "runtime" ]]; then
    rm -rf "/usr/share/doc/" "/usr/share/man/" "/usr/share/icons/" "/usr/share/locale/"
fi
# 安装lib的dev包
if [[ "$MODEL" == "develop" ]]; then
    # 遍历所有以lib开头不以-dev结尾的包
    dpkg-query -W -f='${binary:Package}\n' | awk -F':' '{print $1}' | grep '^lib' | grep -v '\-dev$' | while IFS= read -r pkg; do
        # 获取包的源码包
        source=$(apt-cache show "$pkg"|grep ^Source||echo Source: "$pkg")
        # 通过反向依赖查询获取对应的dev包
        apt-cache rdepends "$pkg" | grep '\-dev$' | awk '{$1=$1; print}' |  while IFS= read -r devPkg; do
            # 获取dev包的源码包，有些dev包本身就是源码包，当获取不到Source是，将devPkg当作源码包名
            devSource=$(apt-cache show "$devPkg"|grep ^Source||echo Source: "$devPkg")
            # libcurl4-gnutls-dev和libcurl4-openssl-dev冲突
            if [ "$devPkg" == "libcurl4-gnutls-dev" ]; then
                break
            fi
            # 安装相同source的dev包
            if [ "$source" == "$devSource" ]; then
                echo "$devPkg $pkg"
                echo "$devPkg $pkg" >> /tmp/dev.packages.list
                break
            fi
        done
    done

    cat /tmp/dev.packages.list | awk '{print $1}' | xargs apt-get install -y
fi

# 清理apt残留
apt-get -y autoremove --purge
apt-get clean

# apt生成的配置文件权限是444，会在构建玲珑时因无法复制出错
chmod 644 /etc/apt/apt.conf.d/01autoremove-kernels
# ldconfig 需要
touch /etc/ld.so.cache~ /etc/ld.so.conf.d/zz_deepin-linglong-app.conf