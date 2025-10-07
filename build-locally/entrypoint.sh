#! /usr/bin/env bash

ZEPHYR_VERSION="4.1.0"
BUILD_DIR="$(mktemp -d)"
BASE_DIR="/tmp/zmk-config"
ZMK_CONFIG_DIR="$BASE_DIR/config"

export "base_dir=$BASE_DIR"
export "zephyr_version=${ZEPHYR_VERSION}"

board="nice_nano_v2"

mkdir -p "$BASE_DIR"
cp -Rf $LILY58/config "$BASE_DIR"

# we are not copyin recursively because now we have this temp directory that is enormeus
# cp -R $LILY58/boards "$BASE_DIR"
# cp -R $LILY58/config "$BASE_DIR"
# cp -R $LILY58/zephyr "$BASE_DIR"
# we probably dont need to copy since we can reference this from EXTRA_MODULES

git config --global --add safe.directory "$BASE_DIR"
git config --global --add safe.directory "$BUILD_DIR"

west init -l "$ZMK_CONFIG_DIR"

cd "$BASE_DIR"
echo "=====> Update west ..."
west update --fetch-opt=--filter=tree:0
echo "=====> west zephyr export ..."
west zephyr-export

artifact_name=splitkb_aurora_lily58_left-nice_nano_v2-zmk
export artifact_name=$artifact_name
export display_name="splitkb_aurora_lily58_left nice_nano_v2"
left=$(mktemp -d)
west build -p always -s zmk/app -d "$left" -b "$board" -S "studio-rpc-usb-uart" -- -DZMK_CONFIG="$ZMK_CONFIG_DIR" -DSHIELD="splitkb_aurora_lily58_left" -DZMK_EXTRA_MODULES="$LILY58" -DCONFIG_ZMK_STUDIO=y || exit 1
cp "$BUILD_DIR/zephyr/zmk.uf2" "/build/splitkb_aurora_lily58_left-nice_nano_v2-zmk.uf2"
cp $left/zephyr/zmk.uf2 "/build/$artifact_name.uf2"

artifact_name=splitkb_aurora_lily58_right-nice_nano_v2-zmk
export artifact_name=$artifact_name
export display_name="splitkb_aurora_lily58_right nice_nano_v2"
right=$(mktemp -d)
west build -p always -s zmk/app -d "$right" -b "$board" -- -DZMK_CONFIG="$ZMK_CONFIG_DIR" -DSHIELD="splitkb_aurora_lily58_right" -DZMK_EXTRA_MODULES="$LILY58" -DCONFIG_ZMK_STUDIO=y || exit 1
cp $right/zephyr/zmk.uf2 "/build/$artifact_name.uf2"

artifact_name="settings_reset-nice_nano_v2-zmk"
export artifact_name=$artifact_name
export display_name="settings_reset nice_nano_v2"
reset=$(mktemp -d)
west build -p always -s zmk/app -d "$reset" -b "$board" -- -DZMK_CONFIG="$ZMK_CONFIG_DIR" -DSHIELD="settings_reset" -DZMK_EXTRA_MODULES="$LILY58" || exit 1
cp $reset/zephyr/zmk.uf2 "/build/$artifact_name.uf2"
