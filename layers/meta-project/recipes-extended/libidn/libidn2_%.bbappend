# libidn2-native can fail during parallel install when libtool relinks
# convenience archives in subdirs. Serialize install to avoid this race.
PARALLEL_MAKEINST = ""

# Avoid native relink collision between bundled unistring convenience library
# and external -lunistring by forcing the included implementation.
EXTRA_OECONF:append:class-native = " --with-included-libunistring"
DEPENDS:remove:class-native = " libunistring-native"
