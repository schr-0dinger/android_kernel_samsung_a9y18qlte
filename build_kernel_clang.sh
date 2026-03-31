#!/bin/bash

set -e

KERNEL_DIR=$(cd "$(dirname "$0")" && pwd)
CLANG_BIN="$KERNEL_DIR/../proton-clang/bin"
CLANG="$CLANG_BIN/clang"
GCC_BIN="$KERNEL_DIR/../aarch64-linux-android-4.9-toolchain/bin"
TARGET_CROSS="$GCC_BIN/aarch64-linux-android-"

if [ ! -x "$CLANG" ]; then
	echo "error: clang not found at $CLANG" >&2
	exit 1
fi

if [ ! -x "${TARGET_CROSS}gcc" ]; then
	echo "error: gcc toolchain not found at ${TARGET_CROSS}gcc" >&2
	exit 1
fi

mkdir -p "$KERNEL_DIR/out"

make -C "$KERNEL_DIR" O="$KERNEL_DIR/out" ARCH=arm64 \
  CC="$CLANG" \
  HOSTCC=gcc \
  HOSTCXX=g++ \
  HOSTLD=ld \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE="$TARGET_CROSS" \
  VARIANT_DEFCONFIG=sdm660_sec_a9y18qlte_eur_open_defconfig \
  sdm660_sec_defconfig \
  SELINUX_DEFCONFIG=selinux_defconfig

scripts/config --file "$KERNEL_DIR/out/.config" \
  --disable MODULE_SIG \
  --disable MODULE_SIG_FORCE \
  --disable MODULE_SIG_ALL \
  --disable SYSTEM_TRUSTED_KEYRING \
  --set-str SYSTEM_TRUSTED_KEYS ""

make -C "$KERNEL_DIR" O="$KERNEL_DIR/out" ARCH=arm64 \
  CC="$CLANG" \
  HOSTCC=gcc \
  HOSTCXX=g++ \
  HOSTLD=ld \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE="$TARGET_CROSS" \
  olddefconfig

make -j4 -C "$KERNEL_DIR" O="$KERNEL_DIR/out" ARCH=arm64 \
  CC="$CLANG" \
  HOSTCC=gcc \
  HOSTCXX=g++ \
  HOSTLD=ld \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE="$TARGET_CROSS" \
  Image.gz-dtb

cp "$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb" \
  "$KERNEL_DIR/arch/arm64/boot/Image.gz-dtb"
