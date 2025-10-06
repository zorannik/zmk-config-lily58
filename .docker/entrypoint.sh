#! /usr/bin/env bash

ZEPHYR_VERSION="4.1.0"
BUILD_DIR="$(mktemp -d)"
BASE_DIR="/tmp/zmk-config"
ZMK_CONFIG_DIR="$BASE_DIR/config"

cat <<-EOF
Base dir: $BASE_DIR
Build dir: $BUILD_DIR
ZMK CFG: $ZMK_CONFIG_DIR
cp -R "$LILY58/config" "$ZMK_CONFIG_DIR"
cp -R "$LILY58/*" "$BUILD_DIR"
EOF

board="nice_nano_v2"
shield_left="splitkb_aurora_lily58_left"
shield_right="splitkb_aurora_lily58_right"
zmk_load_arg=" -DZMK_EXTRA_MODULES=$BUILD_DIR"

mkdir -p "$BASE_DIR"
cp -Rf $LILY58/config "$ZMK_CONFIG_DIR"
cp -Rf $LILY58/* "$BUILD_DIR"

git config --global --add safe.directory "$BASE_DIR"
git config --global --add safe.directory "$BASE_DIR/zephyr"
git config --global --add safe.directory "$BUILD_DIR"
git config --global --add safe.directory "$BUILD_DIR/zephyr"

# export "CMAKE_PREFIX_PATH=$BUILD_DIR/zephyr:$CMAKE_PREFIX_PATH"
export "base_dir=$BASE_DIR"
export "build_dir=$BUILD_DIR"
export "zephyr_version=${ZEPHYR_VERSION}"
export "extra_west_args=-S studio-rpc-usb-uart"
export "extra_cmake_args=${shield:+-DSHIELD=\"$shield\"}${zmk_load_arg}"
export "display_name=${shield:+$shield_left - }${board}"
export "artifact_name=${artifact_name:-${shield:+$shield-}${board}-zmk}"

west init -l "$BASE_DIR/config"

cd "$BASE_DIR"
echo "Update west ..."
west update --fetch-opt=--filter=tree:0
echo "west zephyr export ..."
west zephyr-export

west build -s zmk/app -d "$BUILD_DIR" -b "nice_nano_v2" -S "studio-rpc-usb-uart" -- -DZMK_CONFIG="$ZMK_CONFIG_DIR" -DSHIELD="splitkb_aurora_lily58_left" -DZMK_EXTRA_MODULES="$BUILD_DIR" -DCONFIG_ZMK_STUDIO=y || exit 1
cp "$BUILD_DIR/zephyr/zmk.uf2" "/build/splitkb_aurora_lily58_left-nice_nano_v2-zmk.uf2"

export "display_name=${shield:+$shield_right - }${board}"
west build -s zmk/app -d "$BUILD_DIR" -b "nice_nano_v2" -S "studio-rpc-usb-uart" -- -DZMK_CONFIG="$ZMK_CONFIG_DIR" -DSHIELD="splitkb_aurora_lily58_right" -DZMK_EXTRA_MODULES="$BUILD_DIR" -DCONFIG_ZMK_STUDIO=y || exit 1
cp "$BUILD_DIR/zephyr/zmk.uf2" "/build/splitkb_aurora_lily58_right-nice_nano_v2-zmk.uf2"
