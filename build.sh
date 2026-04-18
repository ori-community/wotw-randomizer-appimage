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

curl -fSL -o proton-ge.tar.gz https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-34/GE-Proton10-34.tar.gz
curl -fSL -o appimagetool https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage

sha256sum -c << EOF
51c580b66a833c73998fe00f0717eeac57197654040a2f2ed5189e3ee68d773d  proton-ge.tar.gz
a6d71e2b6cd66f8e8d16c37ad164658985e0cf5fcaa950c90a482890cb9d13e0  appimagetool
EOF

if [ $? != 0 ]; then
  echo "Checksum validation failed."
  exit 1
fi

chmod u+x ./appimagetool

echo "Extracting Proton-GE"
mkdir -p appdir/opt/proton-ge
tar -v --extract --file proton-ge.tar.gz --strip-components=1 -C appdir/opt/proton-ge

echo "Building AppImage"
ARCH=x86_64 ./appimagetool ./appdir WotwRandomizer.AppImage