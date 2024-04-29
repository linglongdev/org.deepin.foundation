#!/bin/bash

# 这个脚本用于检查develop比runtime多出非dev的lib包，这些包是有构建工具或dev包引入的
# 为减少developer和runtime差异，多出的lib包应该安装到runtime中。

DISTRO=$1
ARCH=$2

diff "create_rootfs/$DISTRO/$ARCH.runtime.packages.list" "create_rootfs/$DISTRO/$ARCH.develop.packages.list" |
 grep "^> lib" |
 grep -v dev$ |
 grep -v bin$ |
 awk '{print $2}'