#!/usr/bin/env bash

set -e

# BEFORE running build.sh, a prebuilt version of the randomizer
# install data directory should be placed into appdir/opt/wotw-randomizer.
# E.g. the launcher binary should be at
# appdir/opt/wotw-randomizer/Ori and the Will of the Wisps Randomizer

if [ ! -d appdir/opt/wotw-randomizer ]; then
  echo "appdir/opt/wotw-randomizer does not exist."
  echo "Make sure you copy a prebuilt installation data directory for Linux to that location before running this build script."
  exit 1
fi

echo "Building AppRun binary"
(
  cd apprun
  cmake -DCMAKE_BUILD_TYPE=Release -B build
  cmake --build build
)

echo "Copying AppRun binary into AppDir"
cp -v apprun/build/AppRun appdir/AppRun

[ -f wine.rpm ] || curl -fSL -o wine.rpm https://dl.winehq.org/wine-builds/fedora/44/x86_64/wine-staging-11.20-1.1.x86_64.rpm
[ -f dxvk.tar.gz ] || curl -fSL -o dxvk.tar.gz https://github.com/doitsujin/dxvk/releases/download/v3.1.1/dxvk-3.1.1.tar.gz
[ -f appimagetool ] || curl -fSL -o appimagetool https://github.com/pkgforge-dev/Anylinux-appimagetool/releases/download/0.5.6/appimagetool-full-x86_64-linux

sha256sum -c << EOF
0256454af5b40043af19a10c4b2fa61f179df6fcf6141b2f95929a011c37874e  wine.rpm
40565b4a724aadc4433fa4e010b4b23916d9b1f1baeee64e17186db94f54e608  dxvk.tar.gz
a92214d831d234d1be31699657c572799e5c8417c9abf129e2f748cc9c612f85  appimagetool
EOF

if [ $? != 0 ]; then
  echo "Checksum validation failed."
  exit 1
fi

chmod u+x ./appimagetool

echo "Extracting Wine"
mkdir -p appdir/opt/wine
rpm2cpio wine.rpm | bsdtar -xvf - -C appdir/opt/wine --strip-components=3

echo "Extracting DXVK"
mkdir -p appdir/opt/dxvk
tar -v --extract --file dxvk.tar.gz --strip-components=1 -C appdir/opt/dxvk

echo "Building AppImage"
./appimagetool -n WotwRandomizer.AppImage ./appdir
