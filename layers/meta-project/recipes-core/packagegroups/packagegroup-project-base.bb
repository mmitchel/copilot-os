SUMMARY = "Project base packagegroup"
DESCRIPTION = "Base package set for project images"

inherit packagegroup

RDEPENDS:${PN} = " \
    packagegroup-meta-networking \
    packagegroup-container \
    packagegroup-security-tpm-i2c \
    "
