#!/bin/bash
set -e
sudo chroot $1  /bin/bash -c 'dpkg --purge --force-all uos-license-upgrade libdbus-1-3 libdouble-conversion1 libglib2.0-0 libpcre2-16-0 libqt5core5a libqt5dbus5 libqt5network5'
