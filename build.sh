#!/bin/bash

#set -e

KERNEL_DEFCONFIG=cepheus_defconfig
ANYKERNEL3_DIR=$PWD/AnyKernel3/
FINAL_KERNEL_ZIP=CANBERRY8.0-OSS.zip

# Kernel Details
VER=.8.0-OSS
BASE_AK_VER=CANBERRY
AK_VER=$BASE_AK_VER$VER
export LOCALVERSION=-$AK_VER
export KBUILD_BUILD_USER=Lovieta
export KBUILD_BUILD_HOST=IxoraLT

# paths
TC=${HOME}/kernel/prebuilts

PATH=${TC}/clang-r416183b1/bin:$PATH

export LLVM=1
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
export USE_CCACHE=1

# Speed up build process
MAKE="./makeparallel"

make O=out ARCH=arm64 $KERNEL_DEFCONFIG

START=$(date +"%s")

make ARCH=arm64 \
	O=out \
	CC=clang \
	AR=llvm-ar \
        LD=ld.lld \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        -j$(nproc --all) | tee ${HOME}/CANBERRY8.0-OSS/out/kernel.log


echo -e "$yellow**** Verify Image.gz-dtb ****$nocol"
ls $PWD/out/arch/arm64/boot/Image.gz-dtb

echo -e "$yellow**** Verifying AnyKernel3 Directory ****$nocol"
ls $ANYKERNEL3_DIR
echo -e "$yellow**** Removing leftovers ****$nocol"
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Copying Image.gz-dtb ****$nocol"
cp $PWD/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL3_DIR/

echo -e "$yellow**** Time to zip up! ****$nocol"
cd $ANYKERNEL3_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP ${HOME}/kernel/$FINAL_KERNEL_ZIP

echo -e "$yellow**** Done, here is your checksum ****$nocol"
cd ..
rm -rf $ANYKERNEL3_DIR/$FINAL_KERNEL_ZIP
rm -rf $ANYKERNEL3_DIR/Image.gz-dtb
#rm -rf out/

END=$(date +"%s")
DIFF=$((END - START))
echo -e '\033[01;32m' "Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds" || exit
sha1sum $KERNELDIR/$FINAL_KERNEL_ZIP
