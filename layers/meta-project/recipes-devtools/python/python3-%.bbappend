# Clamp SOURCE_DATE_EPOCH for Python package builds so wheel ZIP timestamps
# are never before 1980-01-01 (ZIP format lower bound).
do_compile:prepend() {
    _python_wheel_class_inherited="${@'1' if (bb.data.inherits_class('setuptools3', d) or bb.data.inherits_class('setuptools3_legacy', d) or bb.data.inherits_class('python_setuptools_build_meta', d) or bb.data.inherits_class('python_setup_tools_build_meta', d) or bb.data.inherits_class('python_pep517', d)) else '0'}"
    if [ "${_python_wheel_class_inherited}" = "1" ]; then
        bbnote "${PN}: python wheel related class inherited"
        if [ -z "${SOURCE_DATE_EPOCH}" ] || [ "${SOURCE_DATE_EPOCH}" -lt 315532800 ]; then
            export SOURCE_DATE_EPOCH=315532800
        fi
    fi
}
