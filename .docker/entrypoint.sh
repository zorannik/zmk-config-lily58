#! /usr/bin/env bash

# BUILD_DIR="$(mktemp -d)"
ZEPHYR_VERSION="4.1.0"
BUILD_DIR="/tmp/zmk-config"

board="nice_nano_v2"
shield_left="splitkb_aurora_lily58_left"
shield_right="splitkb_aurora_lily58_right"

mkdir -p "$BUILD_DIR"
cp -R /zmk-keyboard/* "$BUILD_DIR"
git config --global --add safe.directory "$BUILD_DIR"
git config --global --add safe.directory "$BUILD_DIR/zephyr"

export "CMAKE_PREFIX_PATH=$BUILD_DIR/zephyr:$CMAKE_PREFIX_PATH"
export "base_dir=$BUILD_DIR"
export "zephyr_version=${ZEPHYR_VERSION}"
export "extra_west_args=-S studio-rpc-usb-uart"
zmk_load_arg=" -DZMK_EXTRA_MODULES=$BUILD_DIR"
export "extra_cmake_args=${shield:+-DSHIELD=\"$shield\"}${zmk_load_arg}"
export "display_name=${shield:+$shield_left - }${board}"
export "artifact_name=${artifact_name:-${shield:+$shield-}${board}-zmk}"

printenv

cd "$BUILD_DIR"
west init -l "$BUILD_DIR/config"
west update --fetch-opt=--filter=tree:0
west zephyr-export

if (
  west build -s zmk/app -d "$BUILD_DIR" -b "nice_nano_v2" -S "studio-rpc-usb-uart" \
    -- -DZMK_CONFIG=/tmp/zmk-config/config \
    -DSHIELD="splitkb_aurora_lily58_left" \
    -DZMK_EXTRA_MODULES="$BUILD_DIR" \
    -DCONFIG_ZMK_STUDIO=y
); then
  cp "$BUILD_DIR/zephyr/zmk.uf2" "/build/splitkb_aurora_lily58_left-nice_nano_v2-zmk.uf2"
else
  echo "Build failed miserably!"
fi

sleep 1h
