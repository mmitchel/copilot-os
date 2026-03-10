FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://netplan-docker-networks.py \
    file://netplan-docker-networks.service \
"

do_install:append() {
    install -d ${D}${libexecdir}/netplan/plugins
    install -m 0755 ${WORKDIR}/netplan-docker-networks.py \
        ${D}${libexecdir}/netplan/plugins/netplan-docker-networks.py

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/netplan-docker-networks.service \
        ${D}${systemd_system_unitdir}/netplan-docker-networks.service
}

FILES:${PN}:append = " \
    ${libexecdir}/netplan/plugins/netplan-docker-networks.py \
    ${systemd_system_unitdir}/netplan-docker-networks.service \
"

SYSTEMD_SERVICE:${PN}:append = " netplan-docker-networks.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
