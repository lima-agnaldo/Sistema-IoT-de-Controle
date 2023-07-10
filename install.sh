#!/bin/sh

# Phoronix Test Suite
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Generic Phoronix Test Suite installer

# To install into a chroot, set $DESTDIR to the corresponding directory.

if [ "X$1" = "X" ]
then
	INSTALL_PREFIX="/usr"
else
	INSTALL_PREFIX="$1"
fi

# Ensure the user is in the correct directory
if [ ! -f pts-core/phoronix-test-suite.php ]
then
	cat <<'EOT'

To install the Phoronix Test Suite you must first change directories to phoronix-test-suite/. For support visit: http://www.phoronix-test-suite.com/

EOT
exit
fi

mkdir -p $DESTDIR$INSTALL_PREFIX
if [ ! -w $DESTDIR$INSTALL_PREFIX ]
then
	echo "ERROR: $DESTDIR$INSTALL_PREFIX is not writable. Run this installer as root or specify a different directory prefix as the first argument sent to this script."
	exit
fi

rm -rf $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/
rm -rf $DESTDIR$INSTALL_PREFIX/share/doc/phoronix-test-suite/

mkdir -p $DESTDIR$INSTALL_PREFIX/bin/
mkdir -p $DESTDIR$INSTALL_PREFIX/share/metainfo/
mkdir -p $DESTDIR$INSTALL_PREFIX/share/applications/
mkdir -p $DESTDIR$INSTALL_PREFIX/share/icons/hicolor/48x48/apps/
mkdir -p $DESTDIR$INSTALL_PREFIX/share/man/man1/
mkdir -p $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/
mkdir -p $DESTDIR$INSTALL_PREFIX/share/doc/phoronix-test-suite/
mkdir -p $DESTDIR$INSTALL_PREFIX/../etc/bash_completion.d/
#mkdir -p $DESTDIR$INSTALL_PREFIX/../usr/lib/systemd/system/
#mkdir -p $DESTDIR$INSTALL_PREFIX/../etc/init/

cp ChangeLog $DESTDIR$INSTALL_PREFIX/share/doc/phoronix-test-suite/
cp COPYING $DESTDIR$INSTALL_PREFIX/share/doc/phoronix-test-suite/
cp AUTHORS $DESTDIR$INSTALL_PREFIX/share/doc/phoronix-test-suite/

cd documentation/
cp -r * $DESTDIR$INSTALL_PREFIX/share/doc/phoronix-test-suite/
cd ..
rm -rf $DESTDIR$INSTALL_PREFIX/share/doc/phoronix-test-suite/man-pages/

cp documentation/man-pages/*.1 $DESTDIR$INSTALL_PREFIX/share/man/man1/
cp pts-core/static/bash_completion $DESTDIR$INSTALL_PREFIX/../etc/bash_completion.d/phoronix-test-suite
cp pts-core/static/images/phoronix-test-suite.png $DESTDIR$INSTALL_PREFIX/share/icons/hicolor/48x48/apps/phoronix-test-suite.png
cp pts-core/static/phoronix-test-suite.desktop $DESTDIR$INSTALL_PREFIX/share/applications/
cp pts-core/static/phoronix-test-suite-launcher.desktop $DESTDIR$INSTALL_PREFIX/share/applications/
cp pts-core/static/com.phoronix_test_suite.phoronix_test_suite.metainfo.xml $DESTDIR$INSTALL_PREFIX/share/metainfo/

mkdir -p $DESTDIR$INSTALL_PREFIX/../usr/lib/systemd/system/
cp deploy/*-systemd/*.service $DESTDIR$INSTALL_PREFIX/../usr/lib/systemd/system/

# mkdir -p $DESTDIR$INSTALL_PREFIX/../etc/init/
# cp pts-core/static/upstart/*.conf $DESTDIR$INSTALL_PREFIX/../etc/init/

rm -rf $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/pts-core
cp -r pts-core $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/
cp -r ob-cache $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/
cp -r deploy $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/
rm -f $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/pts-core/static/phoronix-test-suite.desktop
rm -f $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/pts-core/static/phoronix-test-suite-launcher.desktop
rm -f $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/pts-core/openbenchmarking.org/openbenchmarking-mime.xml
rm -f $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/pts-core/static/bash_completion
rm -f $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/pts-core/static/images/openbenchmarking.png
rm -f $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/pts-core/static/images/%phoronix-test-suite.png


sed 's:export PTS_DIR=$(readlink -f `dirname $0`):export PTS_DIR='"$INSTALL_PREFIX"'\/share\/phoronix-test-suite:g' phoronix-test-suite > $DESTDIR$INSTALL_PREFIX/bin/phoronix-test-suite
chmod +x $DESTDIR$INSTALL_PREFIX/bin/phoronix-test-suite

# sed 's:\$url = PTS_PATH . \"documentation\/index.html\";:\$url = \"'"$INSTALL_PREFIX"'\/share\/doc\/packages\/phoronix-test-suite\/index.html\";:g' pts-core/commands/gui_gtk.php > $DESTDIR$INSTALL_PREFIX/share/phoronix-test-suite/pts-core/commands/gui_gtk.php

# XDG MIME OpenBenchmarking support
if [ "X$DESTDIR" = "X" ] && which xdg-mime >/dev/null && which xdg-icon-resource >/dev/null
then
	#No chroot
	xdg-mime install pts-core/openbenchmarking.org/openbenchmarking-mime.xml
	xdg-icon-resource install --context mimetypes --size 64 pts-core/static/images/openbenchmarking.png application-x-openbenchmarking
else
	#chroot
	mkdir -p $DESTDIR$INSTALL_PREFIX/share/mime/packages/
	mkdir -p $DESTDIR$INSTALL_PREFIX/share/icons/hicolor/64x64/mimetypes/
	cp pts-core/openbenchmarking.org/openbenchmarking-mime.xml $DESTDIR$INSTALL_PREFIX/share/mime/packages/
	cp pts-core/static/images/openbenchmarking.png $DESTDIR$INSTALL_PREFIX/share/icons/hicolor/64x64/mimetypes/application-x-openbenchmarking.png

fi

echo -e "\nPhoronix Test Suite Installation Completed\n
Executable File: $INSTALL_PREFIX/bin/phoronix-test-suite
Documentation: $INSTALL_PREFIX/share/doc/phoronix-test-suite/
Phoronix Test Suite Files: $INSTALL_PREFIX/share/phoronix-test-suite/\n"

if [ "X$DESTDIR" != "X" ]
then
	echo "Installed to chroot: $DESTDIR"
	echo "Please update your desktop and mime-database manually"
fi
