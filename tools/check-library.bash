#!/bin/bash

# 使用appimage的名单列表，检查缺少哪些库文件，仅作参考，不一定要全部补齐

# missing ld-linux.so 在rootfs/lib64/ld-linux-x86-64.so.2
# missing libcidn.so 用apt-file找不到
# missing libSM.so 用apt-file找不到
# missing libusb-1.0.so 感觉不需要放到base里面
# missing libjack.so 用apt-file找不到


wget -c -N https://raw.githubusercontent.com/AppImageCommunity/pkg2appimage/master/excludelist

for file in $(cat excludelist | cut -d "#" -f 1);do
    suffix="${file##*.}"
    if echo "$suffix" | grep -qE '^[0-9]+$'; then
        file="${file%.*}"
    fi
    if [ $(find ./ -name "$file*" 2>/dev/null | wc -l) == 0 ]; then
        echo missing "$file"
    fi
done;