# project-os

Yocto Project workspace built around Poky `scarthgap`, with a project-owned layer (`meta-project`), upstream layers managed by a repo manifest, and CI/container support for reproducible builds.

## Project Layout

- `manifests/`: Repo manifest used to fetch and pin upstream layers.
- `layers/poky`: Upstream Poky layer collection and build scripts.
- `layers/meta-openembedded`: Upstream OpenEmbedded companion layers.
- `layers/meta-project`: Project-owned layer for recipes, templates, and docs.
- `containers/yocto`: Yocto builder container definitions by Ubuntu version.
- `.github/workflows`: CI workflows for image builds and container image publishing.
- `build/`: Local build output directory created by `oe-init-build-env`.

Build flow: manifest sync -> layer checkout -> build env init -> bitbake image build -> CI/container artifacts.

## What Is Included

- Upstream layers:
  - `layers/poky`
  - `layers/meta-openembedded`
- Project layer:
  - `layers/meta-project`
- Repo manifest:
  - `manifests/default.xml`
- VS Code workspace config:
  - `.vscode/settings.json`
  - `.vscode/extensions.json`
  - `.vscode/tasks.json`
- GitHub Actions:
  - `.github/workflows/yocto-build.yml`
  - `.github/workflows/yocto-container-images.yml`
- Yocto build containers:
  - `containers/yocto/ubuntu-20.04/Dockerfile`
  - `containers/yocto/ubuntu-22.04/Dockerfile`
  - `containers/yocto/ubuntu-24.04/Dockerfile`

## Layer Strategy

- `layers/poky` and `layers/meta-openembedded` are upstream and pinned to `scarthgap`.
- `layers/meta-project` contains project-specific recipes, packagegroups, templates, and documentation.
- Root `.gitignore` is configured to ignore upstream layer checkouts and Yocto build artifacts while keeping `meta-project` tracked.

## Quick Start

### 1) Install repo tool (Linux)

```bash
mkdir -p "$HOME/bin"
curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o "$HOME/bin/repo"
chmod +x "$HOME/bin/repo"
export PATH="$HOME/bin:$PATH"
```

### 2) Initialize and sync layers from manifest

```bash
cd <project-root>
repo init -u . -m manifests/default.xml
repo sync -j"$(nproc)"
```

### 3) Initialize build directory

Standard init:

```bash
cd <project-root>
rm -fr build/conf
TEMPLATECONF=$(pwd)/layers/meta-project/conf/templates/default \
  . layers/poky/oe-init-build-env build
```

Init using project template:

```bash
cd <project-root>
rm -fr build/conf
TEMPLATECONF=$(pwd)/layers/meta-project/conf/templates/qemux86-64 \
  . layers/poky/oe-init-build-env build
```

```bash
cd <project-root>
rm -fr build/conf
TEMPLATECONF=$(pwd)/layers/meta-project/conf/templates/qemuarm64 \
  . layers/poky/oe-init-build-env build
```

### 4) Build images

```bash
bitbake core-image-minimal
bitbake core-image-full-cmdline
```

Project image (from `meta-project`):

```bash
bitbake core-image-project
```

Build from the Yocto container:

```bash
bash ./containers/yocto/ubuntu-22.04/run-bitbake.sh core-image-project
```

Alternative container versions:

```bash
bash ./containers/yocto/ubuntu-20.04/run-bitbake.sh core-image-project
bash ./containers/yocto/ubuntu-24.04/run-bitbake.sh core-image-project
```

Optional environment variables:

```bash
TEMPLATE=qemux86-64 BUILD_DIR=build IMAGE_TAG=project-os/yocto:ubuntu-22.04 \
bash ./containers/yocto/ubuntu-22.04/run-bitbake.sh core-image-minimal
```

### 5) Run the built image in QEMU

From the workspace root, initialize the build environment if it is not already active:

```bash
cd <project-root>
rm -fr build/conf
TEMPLATECONF=$(pwd)/layers/meta-project/conf/templates/default \
. layers/poky/oe-init-build-env build
```

Run the default machine image (`qemux86-64`) in headless mode:

```bash
runqemu qemux86-64 core-image-full-cmdline nographic slirp
```

Run the project image in headless mode:

```bash
runqemu qemux86-64 core-image-project nographic slirp
```

If you want a graphical window instead of serial console output, remove `nographic`:

```bash
runqemu qemux86-64 core-image-full-cmdline slirp
```

Yocto deploy artifacts for QEMU are written to:

```bash
build/tmp/deploy/images/qemux86-64/
```

### 6) Run a local PR service (prserv) and capture changes

Use a local PR service to keep package revision (`PR`) increments consistent across builds.

Start local `prserv` (creates/uses a local sqlite DB):

```bash
cd <project-root>
mkdir -p build/cache
bitbake-prserv --start \
  --host 127.0.0.1 \
  --port 8585 \
  --file build/cache/prserv.sqlite3 \
  --log build/cache/prserv.log
```

Configure the active build to use that server:

```bash
cd <project-root>
grep -q '^PRSERV_HOST' build/conf/local.conf || \
  echo 'PRSERV_HOST = "127.0.0.1:8585"' >> build/conf/local.conf
```

Initialize a baseline snapshot from `prserv`:

```bash
cd <project-root>
mkdir -p build/prserv-snapshots
layers/poky/scripts/bitbake-prserv-tool export build/prserv-snapshots/prserv-before.conf
```

Run your build:

```bash
cd <project-root>
bitbake core-image-project
```

Capture and review changes after a successful build:

```bash
cd <project-root>
layers/poky/scripts/bitbake-prserv-tool export build/prserv-snapshots/prserv-after.conf
diff -u build/prserv-snapshots/prserv-before.conf build/prserv-snapshots/prserv-after.conf
```

Stop local `prserv` when done:

```bash
cd <project-root>
bitbake-prserv --stop --host 127.0.0.1 --port 8585
```

Notes:

- `bitbake-prserv-tool export` output files must end with `.conf` or `.inc`.
- The first export may already contain entries if your PR database is not empty.
- Keep the same `prserv.sqlite3` across builds to preserve revision history.

### 7) Sync Yocto caches to S3 with s3cmd

Use this to publish and reuse shared Yocto caches from `build/downloads` and `build/sstate-cache`.

Install and configure `s3cmd` once:

```bash
sudo apt-get update
sudo apt-get install -y s3cmd
s3cmd --configure
```

Set your bucket and prefix:

```bash
cd <project-root>
S3_BUCKET=s3://my-yocto-cache-bucket
S3_PREFIX=project-os/scarthgap
```

Preview upload changes (dry run):

```bash
s3cmd sync --dry-run build/downloads/ ${S3_BUCKET}/${S3_PREFIX}/downloads/
s3cmd sync --dry-run build/sstate-cache/ ${S3_BUCKET}/${S3_PREFIX}/sstate-cache/
```

Upload local cache updates:

```bash
s3cmd sync build/downloads/ ${S3_BUCKET}/${S3_PREFIX}/downloads/
s3cmd sync build/sstate-cache/ ${S3_BUCKET}/${S3_PREFIX}/sstate-cache/
```

Restore caches from S3 into a clean workspace:

```bash
mkdir -p build/downloads build/sstate-cache
s3cmd sync ${S3_BUCKET}/${S3_PREFIX}/downloads/ build/downloads/
s3cmd sync ${S3_BUCKET}/${S3_PREFIX}/sstate-cache/ build/sstate-cache/
```

Upload OSTree repository (`ostree_repo`) to S3:

```bash
cd <project-root>
MACHINE=qemux86-64
OSTREE_REPO=build/tmp/deploy/images/${MACHINE}/ostree_repo

# Preview changes first
s3cmd sync --dry-run ${OSTREE_REPO}/ ${S3_BUCKET}/${S3_PREFIX}/ostree_repo/${MACHINE}/

# Upload new and changed objects only (no deletions)
s3cmd sync ${OSTREE_REPO}/ ${S3_BUCKET}/${S3_PREFIX}/ostree_repo/${MACHINE}/
```

Notes:

- Keep trailing `/` on both source and destination paths to sync directory contents as expected.
- These commands do not delete existing files in S3; they only add new objects and update changed ones.
- Consider separate prefixes per branch or distro/machine combination to avoid cache churn.

## VS Code

The workspace includes settings and tasks for Yocto/BitBake:

- BitBake extension paths are preconfigured for this layout.
- Build output paths are excluded from search/watcher for performance.
- Tasks are provided for common image builds and layer inspection.

## CI

### Yocto image build workflow

`.github/workflows/yocto-build.yml` builds:

- `core-image-minimal`
- `core-image-full-cmdline`

### Container image workflow

`.github/workflows/yocto-container-images.yml` builds Yocto builder images for:

- Ubuntu 20.04
- Ubuntu 22.04
- Ubuntu 24.04

It saves each image as an artifact (`.tar.zst`) and can optionally push to GHCR.

## Notes

- This project workspace was created and is actively maintained with GitHub Copilot assistance.
- Copilot-managed areas include Yocto layer scaffolding, manifest/workflow updates, container definitions, and editor/task configuration.
- If BitBake tools complain about missing host tools on local machines, install required packages (for example `lz4` provides `lz4c` on Ubuntu).
- For clean/reproducible automation, prefer the provided container images and GitHub Actions workflows.
