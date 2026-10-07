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

curl -fSL -o wine.rpm https://dl.winehq.org/wine-builds/fedora/43/x86_64/wine-staging-11.7-1.1.x86_64.rpm
curl -fSL -o dxvk.tar.gz https://github.com/doitsujin/dxvk/releases/download/v2.7.1/dxvk-2.7.1.tar.gz
curl -fSL -o appimagetool https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage

sha256sum -c << EOF
689a8f946048ae74646b63bda653a9354b806e387f656f2ca2aac8bff9058974  wine.rpm
d85ce7c79f57ecd765aaa1b9e7007cb875e6fde9f6d331df799bce73d513ce87  dxvk.tar.gz
95cbe7cce9717fce90c484e34052ee7c7f1d7635b33c12525b4776826a7d29b6  appimagetool
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
./appimagetool ./appdir WotwRandomizer.AppImage
