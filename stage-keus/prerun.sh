#!/bin/bash -e

if [ ! -d "${ROOTFS_DIR}" ]; then
	echo "RUNNING PRERUN SH";
	copy_previous
fi
