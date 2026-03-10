BB_NUMBER_THREADS ?= "${@max(1, int(oe.utils.cpu_count() * 75 / 100))}"
BB_NUMBER_PARSE_THREADS ?= "${@max(1, int(oe.utils.cpu_count() * 75 / 100))}"
PARALLEL_MAKE ?= "-j ${@max(1, int(oe.utils.cpu_count() * 75 / 100))}"

TOOLCHAIN = "gcc"

DISTRO_FEATURES:append = " integrity security tpm tpm2 virtualization"
DISTRO_FEATURES:append = " acl alsa bluetooth directfb gobject-introspection-data ipsec ipv4 ipv6 keyboard nfc nfs overlayfs pam pci pni-names polkit pulseaudio seccomp smbfs usbgadget usbhost vfat wifi xattr zeroconf"
DISTRO_FEATURES:append = " wayland x11 opengl opencl vulkan"
DISTRO_FEATURES:remove = " sysvinit 3g"

DISTRO_FEATURES:append = " systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"
VIRTUAL-RUNTIME_base-utils = "packagegroup-core-base-utils"
VIRTUAL-RUNTIME_base-utils-hwclock = "util-linux-hwclock"
VIRTUAL-RUNTIME_base-utils-syslog = "syslog-ng"
VIRTUAL-RUNTIME_dev_manager = "systemd"
VIRTUAL-RUNTIME_graphical_init_manager = "gdm"
VIRTUAL-RUNTIME_init_manager = "systemd"
VIRTUAL-RUNTIME_initscripts = "systemd-compat-units"
VIRTUAL-RUNTIME_login_manager = "shadow-base"
VIRTUAL-RUNTIME_net_manager = "systemd"
VIRTUAL-RUNTIME_syslog = "syslog-ng"
VIRTUAL-RUNTIME_container_engine = "podman"
VIRTUAL-RUNTIME_container_runtime = "virtual-runc"
VIRTUAL-RUNTIME_container_networking = "cni"
VIRTUAL-RUNTIME_container_orchestration = "k3s"
VIRTUAL-RUNTIME_cri = "virtual-containerd"
VIRTUAL-RUNTIME_cni = "cni"

PREFERRED_RPROVIDER_network-configuration = "networkd-dhcp-conf"
PREFERRED_RPROVIDER_ssh = "openssh"

SYSTEMD_DEFAULT_TARGET = "multi-user.target"

NETWORK_MANAGER = "networkmanager"
NETWORKMANAGER_DNS_RC_MANAGER_DEFAULT = "symlink"

INHERIT += "image-buildinfo"
INHERIT += "rm_work"
INHERIT += "image_repo_manifest_native"
INHERIT += "image_extension_project"

IMAGE_FSTYPES:remove = "ostreepush garagesign garagecheck"
IMAGE_NAME_SUFFIX = ""

OSTREE_RMDIR_HELPER_MSGTYPE ?= "bbnote"

EXTRA_IMAGE_FATURES:append = " ssh-server-${PREFERRED_RPROVIDER_ssh}"
