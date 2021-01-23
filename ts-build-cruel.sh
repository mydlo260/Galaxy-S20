#!/bin/bash
#
# Kernel Build Script v1.0 by ThunderStorms Team
#

LOG=compile_build.log
RDIR=$(pwd)
export K_VERSION="v1.0"
export K_NAME="ThundeRStormS-Kernel"
export K_BASE="ETLL"
export ANDROID_VERSION=110000
export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export CURRENT_ANDROID_MAJOR_VERSION=r
export BUILD_PLATFORM_VERSION=11
ANDROID=OneUI-R

# export BUILD_CROSS_COMPILE=/home/nalas/kernel/AiO-S10-TS/toolchain/gcc-cfp/gcc-cfp-jopp-only/aarch64-linux-android-4.9/bin/aarch64-linux-android-
# export CROSS_COMPILE=$BUILD_CROSS_COMPILE
OUTDIR=$RDIR/arch/arm64/boot
DTSDIR=$RDIR/arch/arm64/boot/dts/exynos
DTBDIR=$OUTDIR/dtb
DTBTOOL=$RDIR/tools/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0

# MAIN PROGRAM
# ------------

MAIN()
{
(
	START_TIME=`date +%T`
    if [ $MODEL = "G980F" ]; then
    ./build mkimg model=G980F name="$K_NAME-$K_BASE-$ANDROID-$MODEL-$K_VERSION" toolchain=cruel +dtb
    fi

	END_TIME=`date +%T`
	echo "Start compile time is $START_TIME"
	echo "End compile time is $END_TIME"
	echo ""
	echo "Your flasheable release can be found in the builds folder with name :"
	echo "$K_NAME-$K_BASE-$ANDROID-$MODEL-$K_VERSION-`date +%Y-%m-%d`.img"
	echo ""
) 2>&1 | tee -a ./$LOG
}

BUILD_FLASHABLES()
{
	cd $RDIR/builds
	mkdir temp2
	cp -rf zip-OneUIR/common/. temp2
    cp -rf *.img temp2/
	cd temp2
	echo ""
	echo "Compressing kernels..."
	tar cv *.img | xz -9 > kernel.tar.xz
	echo "Copying kernels to ts folder..."
	mv kernel.tar.xz ts/
	# mv *.img ts/

    rm -rf *.img	
	zip -9 -r ../$ZIP_NAME *

	cd ..
    rm -rf temp2
}

RUN_PROGRAM()
{
    MAIN
    # BUILD_DTBO
    # BUILD_DTB
    cp -f boot-$MODEL.img builds/$K_NAME-$K_BASE-$ANDROID-$MODEL-$K_VERSION.img
    cp -f $MODEL-dtb.img builds/zip-OneUIR/common/ts/dtb/$MODEL-dtb.img
    cp -f $MODEL-dtbo.img builds/zip-OneUIR/common/ts/dtb/$MODEL-dtbo.img
}

RUN_PROGRAM2()
{
    MAIN
    # BUILD_DTBO
    # BUILD_DTB
    cp -f boot-$MODEL.img builds/$K_NAME-$K_BASE-$ANDROID-$MODEL-$K_VERSION.img
    cp -f $MODEL-dtb.img builds/zip-OneUIR/common/ts/dtb/$MODEL-dtb.img
    cp -f $MODEL-dtbo.img builds/zip-OneUIR/common/ts/dtb/$MODEL-dtbo.img
}

BUILD_DTBO()
{
python tools/dtbo/mkdtboimg.py create /home/nalas/kernel/AiO-S20-TS/arch/arm64/boot/dts/samsung/dtbo.img /home/nalas/kernel/AiO-S20-TS/arch/arm64/boot/dts/samsung/*.dtbo
}

BUILD_DTB()
{
	echo "Processing dts files."
for dts in $DTSFILES; do
	echo "=> Processing: ${dts}.dts"
	"${CROSS_COMPILE}cpp" -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "$DTBDIR/${dts}.dts"
	echo "=> Generating: ${dts}.dtb"
	$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "$DTBDIR/${dts}.dtb" "$DTBDIR/${dts}.dts"
	# dtc -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "$DTBDIR/${dts}.dtb" "$DTBDIR/${dts}.dts"
done

	echo "Generating dtb.img."
tools/dtbo/mkdtboimg.py create /home/nalas/kernel/AiO-S20-TS/arch/arm64/boot/dtb/exynos9830.img --id=0 --rev=0 --custom1=0xff000000 arch/arm64/boot/dts/exynos/exynos9830.dtb

	echo "Done."
}


# RUN PROGRAM
# -----------

# PROGRAM START
# -------------
clear
echo "*****************************************"
echo "*   ThunderStorms Kernel Build Script   *"
echo "*****************************************"
echo ""
echo "    CUSTOMIZABLE STOCK SAMSUNG KERNEL"
echo "                  Cruel"
echo "            Build Kernel for"
echo "-----------------------------------------"
echo "|         S20 for OneUI R ROMs          |"
echo "-----------------------------------------"
echo "(1) SM-G980F"
echo "(2) All variants"
echo ""
read -p "Select an option to compile the kernel: " prompt


if [ $prompt = "1" ]; then
    MODEL=G980F
    ZIP_DATE=`date +%Y%m%d`
    ZIP_NAME=$K_NAME-$MODEL-$ANDROID-$K_VERSION-CRUEL-$ZIP_DATE.zip
    export KERNEL_VERSION="$K_NAME-$K_BASE-$ANDROID-$MODEL-$K_VERSION"
    echo "SM-G980F Selected"
    RUN_PROGRAM
    BUILD_FLASHABLES
elif [ $prompt = "2" ]; then
    ZIP_DATE=`date +%Y%m%d`
    ZIP_NAME=$K_NAME-S20-$ANDROID-$K_VERSION-CRUEL-$ZIP_DATE.zip
    export KERNEL_VERSION="$K_NAME-$K_BASE-$ANDROID-$MODEL-$K_VERSION"
    echo "All variants Selected"
    MODEL=G980F
    echo "Compiling SM-G980F ..."
    RUN_PROGRAM2
    BUILD_FLASHABLES
fi
