FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Replace meta-tegra's stale sota patch with refreshed project copy (same name).
SRC_URI:remove:sota = "file://0001-L4TLauncher-boot-syslinux-instead-of-extlinux-for-os.patch;patchdir=../edk2-nvidia"
SRC_URI:append:sota = " file://0001-L4TLauncher-boot-syslinux-instead-of-extlinux-for-os.patch;patchdir=../edk2-nvidia"
