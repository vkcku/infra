#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)/opentofu"
nix build .#opentofu-json --out-link opentofu.tf.json

cmd="tofu"
for arg in "$@"; do
  cmd+=" $(printf '%q' "$arg")"
done

sops exec-env .env "$cmd"
