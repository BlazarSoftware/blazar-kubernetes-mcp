#!/bin/bash
# Wrapper script for running kubernetes-mcp-server with black-apron namespace config
# Part of BlazarSoftware/blazar-kubernetes-mcp

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export KUBECONFIG="$SCRIPT_DIR/kubeconfig"

if [ ! -f "$KUBECONFIG" ]; then
    echo "Error: kubeconfig not found at $KUBECONFIG" >&2
    echo "Run the setup script to fetch kubeconfig from the K8s host" >&2
    exit 1
fi

npx kubernetes-mcp-server@latest --kubeconfig "$KUBECONFIG"
