#!/bin/bash
# setup.sh — Portable setup for the autonomous engineering team OpenCode project.
# Run this once on a new machine to install all dependencies and register skills.
#
# Usage:
#   ./setup.sh          # install everything
#   ./setup.sh --check  # verify setup without installing
#
# Requirements:
#   - OpenCode CLI (v1.18+ or v2.0.4+)
#   - Node.js 18+ (for npx-based MCP servers)
#   - Git

set -euo pipefail

# --- Detect project root (directory containing this script) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OPENCODE_BIN="${OPENCODE_BIN:-opencode}"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}ℹ  $1${NC}"; }
ok()    { echo -e "${GREEN}✓ $1${NC}"; }
warn()  { echo -e "${YELLOW}⚠ $1${NC}"; }
fail()  { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }

CHECK_ONLY=false
if [[ "${1:-}" == "--check" ]]; then
    CHECK_ONLY=true
    info "Checking setup without installing..."
fi

# --- 1. Verify prerequisites ---
info "Checking prerequisites..."
command -v "$OPENCODE_BIN" >/dev/null 2>&1 || fail "OpenCode CLI not found. Install from https://opencode.ai/docs/docs/getting-started/installation"
command -v git >/dev/null 2>&1 || fail "Git not found"
command -v node >/dev/null 2>&1 || fail "Node.js not found"

OPENCODE_VERSION=$("$OPENCODE_BIN" --version | grep -oP '\d+\.\d+\.\d+' | head -1)
info "OpenCode version: $OPENCODE_VERSION"

# --- 2. Clone skill repos if not present ---
# NOTE: superpowers is NOT cloned locally — it loads via the OpenCode plugin
# (which auto-installs from git+https). Cloning it locally causes duplicate skill warnings.
# Only mattpocock and karpathy are cloned for skills.paths discovery.
SKILLS_DIR=".opencode/skills"
mkdir -p "$SKILLS_DIR"

clone_if_missing() {
    local repo_name="$1"
    local repo_url="$2"
    local target_dir="$SKILLS_DIR/$repo_name"

    if [[ -d "$target_dir" ]]; then
        ok "$repo_name already cloned"
        if ! $CHECK_ONLY; then
            info "Updating $repo_name..."
            cd "$target_dir" && git pull --ff-only 2>/dev/null || true
            cd "$SCRIPT_DIR"
        fi
    else
        if $CHECK_ONLY; then
            warn "$repo_name not yet cloned"
        else
            info "Cloning $repo_name..."
            git clone --depth=1 "$repo_url" "$target_dir"
            ok "$repo_name cloned"
        fi
    fi
}

# superpowers loads via the plugin — do NOT clone it here
# (the plugin auto-installs from git+https to ~/.cache/opencode/packages/)
clone_if_missing "mattpocock-skills" "https://github.com/mattpocock/skills.git"
clone_if_missing "karpathy-skills" "https://github.com/multica-ai/andrej-karpathy-skills.git"

# --- 3. Configure Superpowers plugin ---
if ! $CHECK_ONLY; then
    info "Configuring Superpowers plugin in opencode.json..."
    if ! "$OPENCODE_BIN" plugin add "superpowers@git+https://github.com/obra/superpowers.git" 2>/dev/null; then
        warn "superpowers plugin add failed or already installed — checking config..."
        if ! grep -q "superpowers@git" opencode.json; then
            fail "Could not configure superpowers plugin. Add manually to opencode.json under 'plugin'.\n  \"plugin\": [\"superpowers@git+https://github.com/obra/superpowers.git\"]"
        fi
    fi
    ok "Superpowers plugin configured"
else
    if grep -q "superpowers@git" opencode.json; then
        ok "Superpowers plugin configured in opencode.json"
    else
        warn "Superpowers plugin not yet configured"
    fi
fi

# --- 4. Verify MCP servers are configured ---
info "Verifying MCP server config..."
if grep -q '"filesystem"' opencode.json; then
    ok "Filesystem MCP: configured"
else
    warn "Filesystem MCP: missing from opencode.json"
fi

if grep -q '"github-enterprise"' opencode.json; then
    ok "GitHub Enterprise MCP: configured"
else
    warn "GitHub Enterprise MCP: missing from opencode.json"
fi

if grep -q '"copilot-enterprise"' opencode.json; then
    ok "Copilot Enterprise MCP: configured"
else
    warn "Copilot Enterprise MCP: missing from opencode.json"
fi

if grep -q '"atlassian"' opencode.json; then
    ok "Atlassian MCP (Jira/Confluence): configured"
else
    warn "Atlassian MCP: missing from opencode.json"
fi

# --- 5. Verify agent files ---
info "Verifying agent definitions..."
for agent in project-manager scrum-master developer tester progress-reporter; do
    if [[ -f ".opencode/agents/$agent.md" ]]; then
        ok "Agent: $agent"
        # Verify no model is hardcoded
        if grep -q "^model:" ".opencode/agents/$agent.md"; then
            warn "Agent $agent has a hardcoded model — remove the model: line from frontmatter"
        fi
    else
        fail "Agent file missing: .opencode/agents/$agent.md"
    fi
done

# --- 6. Verify AGENTS.md ---
if [[ -f "AGENTS.md" ]]; then
    ok "AGENTS.md present"
else
    warn "AGENTS.md not found — create one for team-wide instructions"
fi

# --- 7. Set up local output directories ---
mkdir -p src dev-outputs test-outputs progress-reports samples

# --- 8. Summary ---
echo ""
echo -e "${GREEN}═══ Setup Complete ═══${NC}"
echo ""
echo "Configuration files:"
echo "  - opencode.json (project-level OpenCode config)"
echo "  - .opencode/agents/*.md (5 agent definitions)"
echo "  - .opencode/skills/ (2 skill repos: mattpocock, karpathy; superpowers via plugin)"
echo ""
echo "Skill repos installed:"
echo "  - superpowers: 15 skills (brainstorming, tdd, debugging, etc.)"
echo "    Loaded via plugin (auto-registers at OpenCode startup)"
echo "  - mattpocock-skills: 37 skills (tdd, implement, grill, code-review, etc.)"
echo "    Loaded via skills.paths in opencode.json"
echo "  - karpathy-skills: 1 skill, 4 principles (think, simplicity, surgical, goal-driven)"
echo "    Loaded via skills.paths in opencode.json"
echo ""
echo "MCP servers configured (disabled by default):"
echo "  - copilot-enterprise  (MS Copilot Enterprise)"
echo "  - atlassian           (Jira + Confluence)"
echo "  - github-enterprise   (GitHub repos, PRs, issues)"
echo "  - filesystem           (project-scoped file access)"
echo ""
echo "Environment variables needed (set in your shell):"
echo "  - GITHUB_TOKEN         (for GitHub MCP)"
echo "  - COPILOT_ENTERPRISE_URL (for Copilot Enterprise MCP)"
echo ""
echo "Usage:"
echo "  opencode run --agent project-manager \\\\"
echo "    \"We're building a new feature. Follow doc-mode.md to start.\""
echo ""
echo "  # Or use QnA mode for interactive project discovery:"
echo "  opencode run --agent project-manager \\\\"
echo "    \"You are in qna-mode. Ask 5-7 targeted questions, check MCP availability,"
echo "      gather MCP context, write context.md with mcp_status flags, then delegate to scrum-master.\""
echo ""
if ! $CHECK_ONLY; then
    echo "Restart OpenCode for all changes to take effect."
fi
