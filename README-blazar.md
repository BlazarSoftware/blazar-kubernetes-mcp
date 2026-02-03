# BlazarSoftware Kubernetes MCP Server

This is a fork of [containers/kubernetes-mcp-server](https://github.com/containers/kubernetes-mcp-server) configured for the BlazarSoftware `black-apron` Kubernetes namespace.

## Setup

1. **Fetch kubeconfig** (requires SSH access to K8s host):
   ```bash
   source .env
   sshpass -p "$SSH_PASS" ssh "$SSH_USER@$K8S_HOST" \
     "echo '$SSH_PASS' | sudo -S cat /etc/rancher/k3s/k3s.yaml" > kubeconfig
   ```

2. **Update server URL** in kubeconfig:
   Change `server: https://127.0.0.1:6443` to `server: https://10.225.0.153:6443`

3. **Verify connectivity**:
   ```bash
   kubectl --kubeconfig=kubeconfig get pods -n black-apron
   ```

## Usage with Claude Code

The MCP server is registered in the parent ringle directory's `.mcp.json`. When Claude Code starts, it will automatically have access to Kubernetes tools for the `black-apron` namespace.

## Configuration Files

- `.env` - SSH credentials (gitignored, create from template)
- `kubeconfig` - Kubernetes config (gitignored, generated via SSH)
- `run-mcp.sh` - Wrapper script to start MCP server

## Security Notes

- Never commit `.env` or `kubeconfig` files
- Consider switching to SSH key authentication for production
- The kubeconfig contains cluster admin credentials - handle with care
