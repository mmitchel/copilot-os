SUMMARY = "initramfs-framework module for LUKS rootfs unlocking"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

RDEPENDS:${PN} = "initramfs-framework-base cryptsetup util-linux-blkid"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/initramfs-framework:"
SRC_URI = "file://luks"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/luks ${D}/init.d/08-luks
}

FILES:${PN} = "/init.d/08-luks"
