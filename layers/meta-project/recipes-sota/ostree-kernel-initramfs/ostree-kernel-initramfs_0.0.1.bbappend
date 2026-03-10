do_install() {
    kernelver="$(cat ${DEPLOY_DIR_IMAGE}/kernel-abiversion)"
    kerneldir=${D}${KERNEL_BUILD_ROOT}$kernelver
    install -d $kerneldir

    install -m 0644 ${DEPLOY_DIR_IMAGE}/${OSTREE_KERNEL} $kerneldir/vmlinuz

    if [ "${KERNEL_IMAGETYPE}" = "fitImage" ]; then
        if [ -n "${INITRAMFS_IMAGE}" ]; then
            touch $kerneldir/initramfs.img
        fi
    else
        if [ -n "${INITRAMFS_IMAGE}" ]; then
            initramfs_src=""
            for fstype in ${INITRAMFS_FSTYPES}; do
                candidate="${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE}-${MACHINE}.${fstype}"
                if [ -f "$candidate" ]; then
                    initramfs_src="$candidate"
                    break
                fi
            done

            if [ -z "$initramfs_src" ]; then
                bbfatal "Unable to find initramfs artifact for ${INITRAMFS_IMAGE}-${MACHINE} in INITRAMFS_FSTYPES='${INITRAMFS_FSTYPES}'"
            fi

            install -m 0644 "$initramfs_src" $kerneldir/initramfs.img
        fi

        if [ ${@ oe.types.boolean('${OSTREE_DEPLOY_DEVICETREE}')} = True ] && [ -n "${OSTREE_DEVICETREE}" ]; then
            mkdir -p $kerneldir/dtb
            for dts_file in ${OSTREE_DEVICETREE}; do
                dts_file_basename=$(basename $dts_file)
                install -m 0644 ${DEPLOY_DIR_IMAGE}/$dts_file_basename $kerneldir/dtb/$dts_file_basename
            done

            if [ ${@ oe.types.boolean('${OSTREE_MULTI_DEVICETREE_SUPPORT}')} = False ]; then
                install -m 0644 $kerneldir/dtb/$(basename $(echo ${OSTREE_DEVICETREE} | awk '{print $1}')) $kerneldir/devicetree
            fi
        fi
    fi
}
