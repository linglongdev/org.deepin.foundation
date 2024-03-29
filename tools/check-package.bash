#!/bin/bash

# 使用appimage的名单列表，检查缺少哪些包，仅作参考，不一定要全部补齐

wget -c -N https://raw.githubusercontent.com/AppImageCommunity/pkg2appimage/master/excludedeblist

for pkg in $(cat excludedeblist | cut -d "#" -f 1);do
    if ! grep -q "^Package: $pkg" rootfs/var/lib/dpkg/status; then
        echo "missing $pkg"
    fi
done;