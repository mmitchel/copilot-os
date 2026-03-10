INITRAMFS_SCRIPTS:append = " initramfs-module-tpm initramfs-module-ostree${@bb.utils.contains('DISTRO_FEATURES', 'luks', ' initramfs-module-luks', '', d)}"
