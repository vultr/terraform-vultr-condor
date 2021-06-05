#!/usr/bin/env bash
set -euo pipefail

KUBECONFIG=$(k0sctl kubeconfig | base64)

jq -n --arg kubeconfig "$KUBECONFIG" '{"kubeconfig":$kubeconfig}'
