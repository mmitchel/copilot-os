# Add project packages here as your layer grows.
IMAGE_INSTALL:append = " packagegroup-project-base"

# poky remove connman for network configuration
IMAGE_INSTALL:remove = " \
	connman \
	connman-plugin-ethernet \
"

# poky-sota injects OTA clients by default; strip them from project images.
IMAGE_INSTALL:remove = " \
	aktualizr \
	aktualizr-info \
	${SOTA_CLIENT_PROV} \
	aktualizr-shared-prov \
	aktualizr-shared-prov-creds \
	aktualizr-device-prov \
	aktualizr-device-prov-hsm \
	aktualizr-resource-control \
	aktualizr-secondary \
	aktualizr-secondary-lib \
	aktualizr-lib \
	aktualizr-configs \
	aktualizr-sotatools-lib \
	garage-sign \
	garage-push \
	garage-check \
"
