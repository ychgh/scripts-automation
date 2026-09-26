#!/usr/bin/env bash
set -euo pipefail

dependency="${1:-github.com/jsonnet-libs/k8s-libsonnet@main}"

if [ ! -f "jsonnetfile.json" ]; then
  jb init
fi

jb install "$dependency"
