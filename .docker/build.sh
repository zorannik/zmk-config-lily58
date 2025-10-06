#! /usr/bin/env bash

$TMPDIR

docker run \
  -it \
  --rm \
  --security-opt label=disable \
  --workdir /zmk-keyboard \
  -v ~/git/github/zorannik/zmk-config-lily58/:/zmk-keyboard \
  -v ~/temp:/temp \
  zmkfirmware/zmk-build-arm:stable /bin/bash

# git config --global --add safe.directory /zmk-keyboard/zephyr
# west init -l config && west update
# export "CMAKE_PREFIX_PATH=/zmk-keyboard/zephyr:$CMAKE_PREFIX_PATH"
west build \
  -S studio-rpc-usb-uart \
  -d /build/left \
  -p \
  -b "nice_nano_v2" \
  -s /zmk-keyboard/zmk/app -- \
  -DZMK_CONFIG="/zmk-keyboard/config" \
  -DSHIELD="splitkb_aurora_lily58_left" \
  -DCONFIG_ZMK_STUDIO=y \
  -DZMK_EXTRA_MODULES="/zmk-keyboard/zmk-config-lily58"

west build -s zmk/app -d "/tmp/tmp.LXXNINcNUt" -b "nice_nano_v2" -S "studio-rpc-usb-uart" \
  -- \
  -DZMK_CONFIG=/tmp/zmk-config/config \
  -DSHIELD="splitkb_aurora_lily58_left" \
  -DZMK_EXTRA_MODULES='/__w/zmk-config-lily58/zmk-config-lily58' \
  -DCONFIG_ZMK_STUDIO=y
