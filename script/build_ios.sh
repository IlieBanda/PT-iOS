#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/ios-device"
GAME_DIR="${PT_IOS_GAME_DIR:-}"
VENDOR="$ROOT/build/vendor"
mkdir -p "$VENDOR" "$BUILD"
ARCHIVE="$VENDOR/MoltenVK-ios.tar"
HASH=b5d947b1660e6e9fed40b9cd2387e160aaab9e80b775c0cef7e14059405178c1
if ! echo "$HASH  $ARCHIVE" | shasum -a 256 -c - >/dev/null 2>&1; then
  curl --fail --location --retry 3 https://github.com/KhronosGroup/MoltenVK/releases/download/v1.4.2/MoltenVK-ios.tar -o "$ARCHIVE.download"
  echo "$HASH  $ARCHIVE.download" | shasum -a 256 -c -
  mv "$ARCHIVE.download" "$ARCHIVE"
fi
if [ ! -d "$VENDOR/MoltenVK" ]; then tar -xf "$ARCHIVE" -C "$VENDOR"; fi
# Reuse fetched upstream sources, but keep all target objects separate from macOS.
FETCH_ARGS=()
for DEPENDENCY in sdl3 zlib whisper; do
  SOURCE="$ROOT/build/macos/_deps/${DEPENDENCY}-src"
  [ -f "$SOURCE/CMakeLists.txt" ] || continue
  NAME="$(basename "$SOURCE" -src | tr '[:lower:]-' '[:upper:]_')"
  FETCH_ARGS+=("-DFETCHCONTENT_SOURCE_DIR_${NAME}=$SOURCE")
done
cmake -S "$ROOT" -B "$BUILD" -G Ninja \
  -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_SYSTEM_PROCESSOR=arm64 \
  -DCMAKE_OSX_SYSROOT=iphoneos -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=18.0 -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
  -DVulkan_INCLUDE_DIR=/opt/homebrew/include \
  -DVulkan_LIBRARY=/opt/homebrew/lib/libvulkan.dylib \
  -DVulkan_GLSLC_EXECUTABLE=/opt/homebrew/bin/glslc \
  -DPT_MOLTENVK_ROOT="$VENDOR/MoltenVK" \
  -DPT_IOS_GAME_DIR="$GAME_DIR" \
  -DPT_UPSCALERS=OFF -DPT_OPENXR=OFF -DPT_METALFX=ON \
  "${FETCH_ARGS[@]}"
cmake --build "$BUILD" --target pt -j 4
python3 "$ROOT/script/audit_nojit.py" "$BUILD/PT.app" > "$ROOT/build/ios-validation.json"
if [ -n "$GAME_DIR" ]; then
  OUTPUT="$ROOT/dist/PT-iOS-with-game-unsigned.ipa"
else
  OUTPUT="$ROOT/dist/PT-iOS-unsigned.ipa"
fi
python3 "$ROOT/script/package_ios.py" "$BUILD/PT.app" "$OUTPUT"
