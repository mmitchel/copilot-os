SUMMARY = "Raspberry Pi USB boot utility"
HOMEPAGE = "https://github.com/raspberrypi/usbboot"
DESCRIPTION = "Build and package rpiboot from raspberrypi/usbboot."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

SRC_URI = "git://github.com/raspberrypi/usbboot.git;branch=master;protocol=https"
SRCREV = "101f2d00d959855ca9acdfa9a6ee427f35d1700c"

S = "${WORKDIR}/git"

inherit pkgconfig

DEPENDS = "libusb1"

# rpiboot is a host/deployment utility; do not build a target package.
COMPATIBLE_HOST = "null"
COMPATIBLE_HOST:class-native = ".*"
COMPATIBLE_HOST:class-nativesdk = ".*"

# Provide native and SDK host-side variants.
BBCLASSEXTEND = "native nativesdk"

do_compile() {
    oe_runmake
}

do_install() {
    oe_runmake INSTALL_PREFIX=${D}${prefix} install
}

FILES:${PN} += "${datadir}/rpiboot"
RDEPENDS:${PN} += "libusb1"
