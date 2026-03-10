SUMMARY = "initramfs-framework module for TPM device setup and key retrieval"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

RDEPENDS:${PN} = "initramfs-framework-base \
    ${@bb.utils.contains_any('MACHINE_FEATURES', 'tpm tpm2', \
        'kernel-module-tpm \
         kernel-module-tpm-tis \
         kernel-module-tpm-tis-core \
         kernel-module-tpm-crb \
         kernel-module-tpm-tis-spi', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'tpm', 'tpm-tools', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'tpm2-tools', '', d)} \
"

inherit allarch

FILESEXTRAPATHS:prepend := "${THISDIR}/initramfs-framework:"
SRC_URI = "file://tpm"

S = "${WORKDIR}"

do_install() {
    install -d ${D}/init.d
    install -m 0755 ${WORKDIR}/tpm ${D}/init.d/07-tpm
}

FILES:${PN} = "/init.d/07-tpm"
