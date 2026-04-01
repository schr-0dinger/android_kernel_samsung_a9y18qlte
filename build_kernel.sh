#!/bin/bash

export PATH=$HOME/toolchain/gcc-4.9/aarch64-linux-android-4.9/bin/:$PATH

mkdir -p out

make -C $(pwd) O=$(pwd)/out ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- \
  KCFLAGS=-mno-android \
  VARIANT_DEFCONFIG=sdm660_sec_a9y18qlte_eur_open_defconfig \
  sdm660_sec_defconfig \
  SELINUX_DEFCONFIG=selinux_defconfig

scripts/config --file $(pwd)/out/.config \
  --disable MODULE_SIG \
  --disable MODULE_SIG_FORCE \
  --disable MODULE_SIG_ALL \
  --disable SYSTEM_TRUSTED_KEYRING \
  --set-str SYSTEM_TRUSTED_KEYS ""

make -C $(pwd) O=$(pwd)/out ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- olddefconfig

# build Image.gz-dtb
make -j4 -C $(pwd) O=$(pwd)/out ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- \
  KCFLAGS=-mno-android Image.gz-dtb

cp out/arch/arm64/boot/Image.gz-dtb $(pwd)/arch/arm64/boot/Image.gz-dtb
