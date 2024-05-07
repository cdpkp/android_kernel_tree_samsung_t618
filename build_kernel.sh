#!/bin/bash

# Download Prebuilt Clang (AOSP)
if [ ! -d $(pwd)/toolchain/clang/host/linux-x86/clang-r383902 ]; then
    echo "Downloading Prebuilt Clang from AOSP..."
    mkdir -p $(pwd)/toolchain/clang/host/linux-x86/clang-r383902
    curl -Lsq https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android11-release/clang-r383902.tar.gz -o clang.tgz
    tar -xzf clang.tgz -C $(pwd)/toolchain/clang/host/linux-x86/clang-r383902
else
    echo "This $(pwd)/toolchain/clang/host/linux-x86/clang-r383902 already exists."
fi

# Download Prebuilt GCC (AOSP)
if [ ! -d $(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 ]; then
    echo "Downloading Prebuilt Clang from AOSP..."
    git clone --depth=1 --single-branch https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android11-release $(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9
else
    echo "This $(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 already exists."
fi

# Install Packages (In case your server don't have this pre-installed)
# Run `sudo apt-get update -y` as well.
echo "Updating build environment..."
sudo apt-get update -y
echo "Update done."

echo "Installing necessary packages..."
sudo apt-get install bison flex rsync bison device-tree-compiler bc cpio -y
echo "Package installation done."

# Exports
export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export ARCH=arm64
export CLANG_TOOL_PATH=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/
export PATH=${CLANG_TOOL_PATH}:${PATH//"${CLANG_TOOL_PATH}:"}
export LD_LIBRARY_PATH=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/lib64
export BSP_BUILD_FAMILY=qogirl6
export DTC_OVERLAY_TEST_EXT=$(pwd)/tools/mkdtimg/ufdt_apply_overlay
export DTC_OVERLAY_VTS_EXT=$(pwd)/tools/mkdtimg/ufdt_verify_overlay_host
export BSP_BUILD_ANDROID_OS=y

# Build command
echo "Compiling..."
make -C $(pwd) O=$(pwd)/out BSP_BUILD_DT_OVERLAY=y CC=clang LD=ld.lld ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- gta8_eur_open_defconfig
make -C $(pwd) O=$(pwd)/out BSP_BUILD_DT_OVERLAY=y CC=clang LD=ld.lld ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- -j$(nproc --all)
echo "Build done."

# Final Build
mkdir -p kernelbuild
echo "Copying Image/.gz into kernelbuild..."
cp -nf $(pwd)/out/arch/arm64/boot/Image $(pwd)/kernelbuild
cp -nf $(pwd)/out/arch/arm64/boot/Image.gz $(pwd)/kernelbuild
echo "Done copying Image/.gz into kernelbuild."

mkdir -p modulebuild
echo "Copying modules into modulebuild..."
cp -nr $(find out -name '*.ko') $(pwd)/modulebuild
echo "Done copying modules into modulebuild."
echo "Check kernelbuild and modulebuild for build final output."

