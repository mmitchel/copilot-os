# Override repo manifest generation to use repo-native in a deterministic way.
# This class intentionally replaces the handler added by image_repo_manifest.bbclass.

do_image[depends] += "repo-native:do_populate_sysroot"
