#!/bin/bash

# Download Prebuilt Clang (AOSP)
if [ ! -d $(pwd)/toolchain/clang/host/linux-x86/clang-r383902 ]; then
    mkdir -p $(pwd)/toolchain/clang/host/linux-x86/clang-r383902
    curl -Lsq https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android11-release/clang-r383902.tar.gz -o clang.tgz
    tar -xzf clang.tgz -C $(pwd)/toolchain/clang/host/linux-x86/clang-r383902
fi

# Download Prebuilt GCC (AOSP)
if [ ! -d $(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 ]; then
    git clone --depth=1 --single-branch https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android11-release $(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9
fi

# Install Packages (In case your server don't have this pre-installed)
# Run `sudo apt-get update -y` as well.
# sudo apt-get update -y
sudo apt-get install bison flex rsync bison device-tree-compiler bc -y

# Exports
export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export ARCH=arm64
export CLANG_TOOL_PATH=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/
export PATH=${CLANG_TOOL_PATH}:${PATH//"${CLANG_TOOL_PATH}:"}
export BSP_BUILD_FAMILY=qogirl6
export DTC_OVERLAY_TEST_EXT=$(pwd)/tools/mkdtimg/ufdt_apply_overlay
export DTC_OVERLAY_VTS_EXT=$(pwd)/tools/mkdtimg/ufdt_verify_overlay_host
export BSP_BUILD_ANDROID_OS=y

# Build command
make -C $(pwd) O=$(pwd)/out BSP_BUILD_DT_OVERLAY=y CC=clang LD=ld.lld ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- gta8_eur_open_defconfig
make -C $(pwd) O=$(pwd)/out BSP_BUILD_DT_OVERLAY=y CC=clang LD=ld.lld ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- -j$(nproc --all)
