#!/usr/bin/env bash
set -euo pipefail

dependency="${1:-github.com/jsonnet-libs/k8s-libsonnet/1.31}"

if [ ! -f "jsonnetfile.json" ]; then
  jb init
fi

jb install "$dependency"
