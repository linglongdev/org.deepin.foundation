#!/bin/sh

tripletList=$(cat /etc/linglong-triplet-list)

# Default directory list: / /runtime /usr
dirs="/runtime /usr ''"
# Update the directory list if LINGLONG_APPID exists
if [ -n "$LINGLONG_APPID" ]; then
    dirs="/opt/apps/$LINGLONG_APPID/files ${dirs}"
fi

for dir in $dirs; do
    # Remove single quotes from the directory
    dir=$(echo "$dir" | tr -d "'")
    PATH=$dir/bin:$PATH

    # Update LIBRARY_PATH and PKG_CONFIG_PATH

    LIBRARY_PATH=$dir/lib:$LIBRARY_PATH
    PKG_CONFIG_PATH=$dir/lib/pkgconfig:$dir/share/pkgconfig:$PKG_CONFIG_PATH
    for triplet in $tripletList; do
        LIBRARY_PATH=$dir/lib/$triplet:$LIBRARY_PATH
        PKG_CONFIG_PATH=$dir/lib/$triplet/pkgconfig:$PKG_CONFIG_PATH
        # Skip the root directory
        if [ -n "$dir" ]; then
            CFLAGS="-I$dir/include/$triplet $CFLAGS"
        fi
    done

    # Skip the root directory
    if [ -n "$dir" ]; then
        XDG_DATA_DIRS=$dir/share:$dir/local/share:$XDG_DATA_DIRS
        XDG_CONFIG_DIRS=$dir/share:$dir/local/share:$XDG_CONFIG_DIRS
        CFLAGS="-I$dir/include $CFLAGS"
    fi
done

# remove trailing colons
export PATH="${PATH%:}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS%:}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS%:}"

# Set these environment variables only during the build
if [ -n "$PREFIX" ]; then
    export LIBRARY_PATH="${LIBRARY_PATH%:}"
    export PKG_CONFIG_PATH="${PKG_CONFIG_PATH%:}"
    export CFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-Wl,-z,relro"
fi

export SUDO_FORCE_REMOVE=yes

# apply runtime profile
if [ -e "/runtime/etc/profile" ]; then
    . /runtime/etc/profile
fi

# apply app profile
if [ -e "/opt/apps/$LINGLONG_APPID/files/etc/profile" ]; then
    . "/opt/apps/$LINGLONG_APPID/files/etc/profile"
fi