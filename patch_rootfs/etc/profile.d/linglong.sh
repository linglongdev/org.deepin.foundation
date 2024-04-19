#!/bin/sh

dirs="$PREFIX /runtime /usr ''"
for dir in $dirs; do
    dir=$(echo "$dir" | tr -d "'")
    PATH=$dir/bin:$PATH
    LIBRARY_PATH=$dir/lib:$dir/lib/$TRIPLET:$LIBRARY_PATH
    PKG_CONFIG_PATH=$dir/lib/pkgconfig:$dir/lib/$TRIPLET/pkgconfig:$dir/share/pkgconfig:$PKG_CONFIG_PATH
    
    # skip root dir
    if [ -n "$dir" ]; then
        XDG_DATA_DIRS=$dir/share:$dir/local/share:$XDG_DATA_DIRS
        XDG_CONFIG_DIRS=$dir/share:$dir/local/share:$XDG_CONFIG_DIRS
    fi
done

# trim end
export PATH="${PATH%:}"
export LIBRARY_PATH="${LIBRARY_PATH%:}"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH%:}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS%:}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS%:}"

# apply runtime profile
if [ -e "/runtime/profile" ]; then
    . /runtime/profile
else
    # TODO should set to org.deepin.Runtime
    export QT_QPA_PLATFORM_PLUGIN_PATH="/runtime/lib/${TRIPLET}/qt5/plugins/platforms"
    export QT_PLUGIN_PATH="/runtime/lib/${TRIPLET}/qt5/plugins"
fi


