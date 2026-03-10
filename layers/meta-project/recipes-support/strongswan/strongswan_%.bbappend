# When tpm DISTRO_FEATURE is enabled (pulling tpm-tools), disable strongswan's tpm2 plugin
# to avoid file conflicts over /usr/bin/tpm_extendpcr
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'tpm', 'tpm2', '', d)}"
