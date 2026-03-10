# meta-project

Project-specific Yocto layer for this workspace.

## Purpose
- Keep all project-owned recipes, packagegroups, images, bbappends, classes, and helper files.
- Separate customizations from upstream layers (`poky` and `meta-openembedded`).

## Layout
- `conf/`: Layer configuration (`layer.conf`).
- `recipes-core/images/`: Project image recipes.
- `recipes-core/packagegroups/`: Project package groups.
- `classes/`: Optional custom `.bbclass` files.
- `files/`: Shared patch/config assets used by recipes.
- `docs/`: Project Yocto documentation.
- `scripts/`: Build and maintenance helper scripts.

## Usage
1. Ensure this layer is listed in `build/conf/bblayers.conf`.
2. Build the provided image recipe:
   - `bitbake core-image-project`
