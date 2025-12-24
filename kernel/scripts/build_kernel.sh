#!/bin/bash
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#
# SPDX-License-Identifier: BSD-3-Clause-Clear
#
# ===================================================
# build_kernel.sh
#
# Tool to build and deploy linux kernel artifacts for iot & compute platforms
#
# Author: Bjordis Collaku <bcollaku@qti.qualcomm.com>
# ===================================================
set -euo pipefail

KERNEL_DIR=${KERNEL_DIR:-qcom-next}

KPATH=$BUILD_TOP/$KERNEL_DIR/arch/arm64/boot
OUT_PATH=$BUILD_TOP/out

DTBS=(
  "$KPATH/dts/qcom/x1e80100-crd.dtb"
  "$KPATH/dts/qcom/hamoa-iot-evk.dtb"
  "$KPATH/dts/qcom/qcs6490-rb3gen2.dtb"
  "$KPATH/dts/qcom/qcs8300-ride.dtb"
  "$KPATH/dts/qcom/qcs9100-ride-r3.dtb"
)

# Clean previous build
rm -rf $OUT_PATH/*;

# Make config
cd $BUILD_TOP/$KERNEL_DIR/
make ARCH=arm64 defconfig qcom.config
# Deploy boot config to out/
cp $BUILD_TOP/$KERNEL_DIR/.config $OUT_PATH

# Make kernel
make ARCH=arm64 -j$(nproc)
# Deploy kernel Image to out/
cp $KPATH/Image $OUT_PATH

# Make modules
mkdir -p $OUT_PATH/modules/
make ARCH=arm64 modules
# Deploy kernel modules to out/
make ARCH=arm64 modules_install INSTALL_MOD_PATH=$OUT_PATH/modules INSTALL_MOD_STRIP=1

# Deploy device tree blobs to out/
for dtb in "${DTBS[@]}"; do
  [ -f "$dtb" ] && cp "$dtb" "$OUT_PATH/"
done
