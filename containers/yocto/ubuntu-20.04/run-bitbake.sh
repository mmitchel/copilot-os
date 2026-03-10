#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/../../.." && pwd)
UBUNTU_VERSION=$(basename -- "${SCRIPT_DIR}")

IMAGE_TAG=${IMAGE_TAG:-project-os/yocto:${UBUNTU_VERSION}}
TEMPLATE=${TEMPLATE:-qemux86-64}
BUILD_DIR=${BUILD_DIR:-build}
TARGET=${1:-core-image-project}

case "${TEMPLATE}" in
  /*)
    TEMPLATECONF_PATH="${TEMPLATE}"
    ;;
  *)
    TEMPLATECONF_PATH="/workspace/project-os/layers/meta-project/conf/templates/${TEMPLATE}"
    ;;
esac

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but was not found in PATH" >&2
  exit 1
fi

docker build \
  --tag "${IMAGE_TAG}" \
  --file "${SCRIPT_DIR}/Dockerfile" \
  "${REPO_ROOT}"

docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp/yocto-home \
  --volume "${REPO_ROOT}:/workspace/project-os" \
  --workdir /workspace/project-os \
  "${IMAGE_TAG}" \
  bash -lc "mkdir -p \"\${HOME}\" && \
    rm -rf \"${BUILD_DIR}/conf\" && \
    TEMPLATECONF=${TEMPLATECONF_PATH} . layers/poky/oe-init-build-env \"${BUILD_DIR}\" >/dev/null && \
    bitbake ${TARGET}"
