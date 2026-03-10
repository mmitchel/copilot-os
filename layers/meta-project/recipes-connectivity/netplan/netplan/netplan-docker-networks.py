#!/usr/bin/env python3

"""Create Docker networks declared in netplan YAML.

This script reads `network.x-docker-networks` entries from files in /etc/netplan.
Each declared network is created if it does not already exist.

network:
  version: 2
  renderer: NetworkManager
  x-docker-networks:
    - name: app-net
      driver: bridge
      attachable: true
      subnet: 172.31.0.0/16
      gateway: 172.31.0.1
      options:
        com.docker.network.bridge.name: br-app
      labels:
        project: project-os
"""

import glob
import logging
import os
import subprocess
import sys

import yaml


LOG = logging.getLogger("netplan-docker-networks")
NETPLAN_DIR = "/etc/netplan"


def run(cmd):
    return subprocess.run(cmd, check=False, capture_output=True, text=True)


def docker_exists():
    result = run(["docker", "--version"])
    return result.returncode == 0


def network_exists(name):
    result = run(["docker", "network", "inspect", name])
    return result.returncode == 0


def bool_flag(enabled, flag):
    return [flag] if bool(enabled) else []


def read_network_specs():
    specs = []
    for path in sorted(glob.glob(os.path.join(NETPLAN_DIR, "*.yaml"))):
        try:
            with open(path, "r", encoding="utf-8") as handle:
                docs = list(yaml.safe_load_all(handle))
        except Exception as exc:  # pragma: no cover
            LOG.warning("Skipping %s: failed to parse YAML: %s", path, exc)
            continue

        for doc in docs:
            if not isinstance(doc, dict):
                continue

            network = doc.get("network")
            if not isinstance(network, dict):
                continue

            declared = network.get("x-docker-networks", [])
            if isinstance(declared, dict):
                declared = [declared]
            if not isinstance(declared, list):
                LOG.warning("Skipping invalid x-docker-networks in %s", path)
                continue

            for item in declared:
                if isinstance(item, dict):
                    specs.append(item)
                else:
                    LOG.warning("Skipping non-dict docker network in %s", path)

    return specs


def create_network(spec):
    name = spec.get("name")
    if not name:
        LOG.warning("Skipping docker network without name: %s", spec)
        return 0

    if network_exists(name):
        LOG.info("Docker network already exists: %s", name)
        return 0

    cmd = [
        "docker",
        "network",
        "create",
        "--driver",
        str(spec.get("driver", "bridge")),
    ]

    cmd.extend(bool_flag(spec.get("attachable", False), "--attachable"))
    cmd.extend(bool_flag(spec.get("internal", False), "--internal"))
    cmd.extend(bool_flag(spec.get("ipv6", False), "--ipv6"))

    for key, value in (spec.get("options") or {}).items():
        cmd.extend(["--opt", f"{key}={value}"])

    for key, value in (spec.get("labels") or {}).items():
        cmd.extend(["--label", f"{key}={value}"])

    if spec.get("subnet"):
        cmd.extend(["--subnet", str(spec["subnet"])])
    if spec.get("gateway"):
        cmd.extend(["--gateway", str(spec["gateway"])])

    cmd.append(name)
    result = run(cmd)

    if result.returncode != 0:
        LOG.error("Failed to create %s: %s", name, result.stderr.strip())
        return result.returncode

    LOG.info("Created docker network: %s", name)
    return 0


def main():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )

    if not docker_exists():
        LOG.warning("docker CLI not available; skipping docker network management")
        return 0

    rc = 0
    for spec in read_network_specs():
        rc = rc or create_network(spec)

    return rc


if __name__ == "__main__":
    sys.exit(main())
