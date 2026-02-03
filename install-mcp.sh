#!/bin/bash
# Install blazar-kubernetes MCP server into Claude Code's configuration
# Usage: ./install-mcp.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_CONFIG_DIR="$HOME/.claude"
CLAUDE_MCP_CONFIG="$CLAUDE_CONFIG_DIR/mcp.json"

# Check prerequisites
if [ ! -f "$SCRIPT_DIR/kubeconfig" ]; then
    echo "Error: kubeconfig not found at $SCRIPT_DIR/kubeconfig"
    echo ""
    echo "To generate kubeconfig, run:"
    echo "  source .env"
    echo "  sshpass -p \"\$SSH_PASS\" ssh \"\$SSH_USER@\$K8S_HOST\" \\"
    echo "    \"echo '\$SSH_PASS' | sudo -S cat /etc/rancher/k3s/k3s.yaml\" > kubeconfig"
    echo ""
    echo "Then update the server URL from 127.0.0.1 to the remote host IP."
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/run-mcp.sh" ]; then
    echo "Error: run-mcp.sh not found"
    exit 1
fi

# Create Claude config directory if needed
mkdir -p "$CLAUDE_CONFIG_DIR"

# Build the MCP server entry
MCP_ENTRY=$(cat <<EOF
{
  "command": "bash",
  "args": ["$SCRIPT_DIR/run-mcp.sh"],
  "env": {
    "K8S_NAMESPACE": "black-apron"
  }
}
EOF
)

# Check if mcp.json exists
if [ -f "$CLAUDE_MCP_CONFIG" ]; then
    # Check if blazar-kubernetes already exists
    if jq -e '.mcpServers["blazar-kubernetes"]' "$CLAUDE_MCP_CONFIG" > /dev/null 2>&1; then
        echo "blazar-kubernetes MCP server already configured in $CLAUDE_MCP_CONFIG"
        echo "Updating configuration..."

        # Update existing entry
        jq --argjson entry "$MCP_ENTRY" '.mcpServers["blazar-kubernetes"] = $entry' \
            "$CLAUDE_MCP_CONFIG" > "$CLAUDE_MCP_CONFIG.tmp" && \
            mv "$CLAUDE_MCP_CONFIG.tmp" "$CLAUDE_MCP_CONFIG"
    else
        echo "Adding blazar-kubernetes to existing MCP configuration..."

        # Add new entry to existing config
        jq --argjson entry "$MCP_ENTRY" '.mcpServers["blazar-kubernetes"] = $entry' \
            "$CLAUDE_MCP_CONFIG" > "$CLAUDE_MCP_CONFIG.tmp" && \
            mv "$CLAUDE_MCP_CONFIG.tmp" "$CLAUDE_MCP_CONFIG"
    fi
else
    echo "Creating new MCP configuration at $CLAUDE_MCP_CONFIG..."

    # Create new config file
    cat > "$CLAUDE_MCP_CONFIG" <<EOF
{
  "mcpServers": {
    "blazar-kubernetes": $MCP_ENTRY
  }
}
EOF
fi

echo ""
echo "Successfully configured blazar-kubernetes MCP server!"
echo ""
echo "Configuration:"
echo "  Config file: $CLAUDE_MCP_CONFIG"
echo "  Kubeconfig:  $SCRIPT_DIR/kubeconfig"
echo "  Namespace:   black-apron"
echo ""
echo "Restart Claude Code to load the new MCP server."
