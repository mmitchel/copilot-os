RPROVIDES:${PN} += "network-configuration"
# Enable ModemManager integration, WWAN support, and dnsmasq DNS handling.
# - modemmanager + wwan: mobile broadband support path
# - dnsmasq: NetworkManager DNS plugin backend
# - man-resolv-conf: lets NetworkManager manage /etc/resolv.conf symlink
PACKAGECONFIG:append = " modemmanager wwan dnsmasq man-resolv-conf"
# Ensure ModemManager support brings in mobile broadband protocol libs.
PACKAGECONFIG:remove = " vala"
