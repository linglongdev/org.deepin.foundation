#!/bin/bash

# 这个脚本用于检查devel多出的so文件不应该有header文件
# 因为这可能会导致构建应用用的devel和运行应用用的runtime有链接差异

temp_file=$(mktemp)
# 统计devel包文件列表
find rootfs \
        -not -path "$rootfs/usr/share/doc/*" \
        -not -path "$rootfs/usr/share/man/*" \
        -not -path "$rootfs/usr/share/icons/*" \
        -printf "/runtime/%P\n" > "$temp_file"

rm so.list || true
# 匹配devel比runtime包多出的so文件
diff org.deepin.foundation.install $temp_file |
 grep -E "^>.+\.so[0-9\.]*$" | # 匹配so文件
 awk '{print $2}' | # 去掉diff开头的>符号
 sed "s/rootfs//" > so.list # 将so文件列表输出到rootfs目录

# 查找多出的so文件来自哪些包
rm pkg.list || true
while IFS= read -r sofile
do
    sofile=$(echo "$sofile" | sed "s#^/runtime##")
    for listfile in $(grep "^$sofile$" rootfs/var/lib/dpkg/info/*.list); do
        pkg=$(echo "$listfile" | awk -F "[:/]" '{print $6}')
        pkg=${pkg%".list"}
        echo "$pkg" >> pkg.list
    done
done < so.list 

cat pkg.list | sort | uniq | grep -v "dev$" | while IFS= read -r pkg
do
    # 这些包不存在于runtime中
    if ! grep -q "^$pkg$" runtime.packages.list; then
        # 去掉包名可能携带的版本号
        pkgPrefix=$(echo "$pkg" | grep -Eo "^[a-z-]*")
        # header一般存放在dev包中，所以要检查dev包是否被安装了
        if grep "$pkgPrefix" devel.packages.list | grep -q dev$; then
            echo "$pkg has devel package, Not installed in runtime"
        fi
    fi
done
