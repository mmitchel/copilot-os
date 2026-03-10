SUMMARY = "initramfs-framework module for OSTree prepare-root"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

RDEPENDS:${PN} = "initramfs-framework-base initramfs-module-rootfs ostree-prepare-root"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/initramfs-framework:"
SRC_URI = "file://ostree"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/ostree ${D}/init.d/91-ostree
}

FILES:${PN} = "/init.d/91-ostree"
