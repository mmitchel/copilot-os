# Remove RPM/DNF package manager data from final rootfs to reduce image size
# and avoid shipping package caches/metadata.
remove_rpm_dnf_data_from_image() {
    # DNF/YUM caches and metadata
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/cache/dnf
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/cache/yum
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/lib/dnf

    # RPM metadata and databases
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/lib/rpm
    rm -rf ${IMAGE_ROOTFS}${nonarch_libdir}/sysimage/rpm
}

ROOTFS_POSTUNINSTALL_COMMAND += "remove_rpm_dnf_data_from_image; "

# Remove DEB/APT package manager data from final rootfs.
remove_deb_apt_data_from_image() {
    # APT package archives and lists
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/cache/apt
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/lib/apt

    # dpkg status/database files and metadata
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/lib/dpkg
}

ROOTFS_POSTUNINSTALL_COMMAND += "remove_deb_apt_data_from_image; "

# Remove IPK/OPKG package manager data from final rootfs.
remove_ipk_opkg_data_from_image() {
    # opkg package cache and state data
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/cache/opkg
    rm -rf ${IMAGE_ROOTFS}${localstatedir}/lib/opkg

    # Some images may place opkg metadata under libdir
    rm -rf ${IMAGE_ROOTFS}${nonarch_libdir}/opkg
}

ROOTFS_POSTUNINSTALL_COMMAND += "remove_ipk_opkg_data_from_image; "

# Save a factory copy of ${localstatedir} in the image and add a tmpfiles rule
# to restore it on systems where ${localstatedir} starts uninitialized.
install_factory_var_seed() {
    install -d ${IMAGE_ROOTFS}${datadir}/factory
    rm -rf ${IMAGE_ROOTFS}${datadir}/factory${localstatedir}
    cp -a ${IMAGE_ROOTFS}${localstatedir} ${IMAGE_ROOTFS}${datadir}/factory${localstatedir}

    install -d ${IMAGE_ROOTFS}${nonarch_libdir}/tmpfiles.d
    cat > ${IMAGE_ROOTFS}${nonarch_libdir}/tmpfiles.d/project-factory-var.conf << EOF
# Copy factory ${localstatedir} tree into ${localstatedir} if it is not initialized yet.
# Type C copies from source only when destination does not exist.
C ${localstatedir} - - - - ${datadir}/factory${localstatedir}
EOF
}

ROOTFS_POSTUNINSTALL_COMMAND += "install_factory_var_seed; "
