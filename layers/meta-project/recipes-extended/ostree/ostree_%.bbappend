PACKAGE_BEFORE_PN:append = " ${PN}-prepare-root"

FILES:${PN}-prepare-root = "${nonarch_libdir}/${BPN}/ostree-prepare-root"

FILES:${PN}-switchroot = "${systemd_system_unitdir}/ostree-prepare-root.service"
RDEPENDS:${PN}-switchroot = "${PN}-prepare-root"
ALLOW_EMPTY:${PN}-switchroot = "1"
