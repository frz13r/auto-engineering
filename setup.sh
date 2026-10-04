#!/usr/bin/env bash
# setup.sh — Portable setup for the autonomous engineering team OpenCode project.
#
# Usage:
#   ./setup.sh          # install pinned skill repos, then validate (incl. resolved config)
#   ./setup.sh --check  # read-only static validation; exits non-zero on any problem.
#                       # Only calls `opencode --version` (if installed), so it never
#                       # fetches or caches anything and runs in CI without OpenCode.
#
# Requirements: git, jq; OpenCode CLI (optional for --check). Optional: uvx
# (team-atlassian MCP), docker (team-github MCP).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OPENCODE_BIN="${OPENCODE_BIN:-opencode}"
MIN_OPENCODE_VERSION="1.18.24"

# Pinned skill sources: name|url|commit
SKILL_REPOS=(
  "mattpocock-skills|https://github.com/mattpocock/skills.git|24fe0ef7737efae15c87225755e9f6f5965e4888"
  "karpathy-skills|https://github.com/multica-ai/andrej-karpathy-skills.git|2c606141936f1eeef17fa3043a72095b4765b9c2"
)
SKILLS_DIR=".opencode/skills"

# Skills the agent prompts depend on: <skill-name>|<path relative to SKILLS_DIR>
REQUIRED_SKILLS=(
  "tdd|mattpocock-skills/skills/engineering/tdd"
  "implement|mattpocock-skills/skills/engineering/implement"
  "implement-spec|mattpocock-skills/skills/engineering/implement-spec"
  "diagnosing-bugs|mattpocock-skills/skills/engineering/diagnosing-bugs"
  "code-review|mattpocock-skills/skills/engineering/code-review"
  "codebase-design|mattpocock-skills/skills/engineering/codebase-design"
  "grill-with-docs|mattpocock-skills/skills/engineering/grill-with-docs"
  "ask-matt|mattpocock-skills/skills/engineering/ask-matt"
  "to-tickets|mattpocock-skills/skills/engineering/to-tickets"
  "grilling|mattpocock-skills/skills/productivity/grilling"
  "karpathy-guidelines|karpathy-skills/skills/karpathy-guidelines"
)
# Must match "skills.paths" in opencode.json
REQUIRED_SKILL_PATHS=(
  ".opencode/skills/mattpocock-skills/skills"
  ".opencode/skills/karpathy-skills/skills"
)

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { printf "${BLUE}ℹ  %s${NC}\n" "$1"; }
ok()   { printf "${GREEN}✓ %s${NC}\n" "$1"; }
warn() { printf "${YELLOW}⚠ %s${NC}\n" "$1"; WARNINGS=$((WARNINGS + 1)); }
fail() { printf "${RED}✗ %s${NC}\n" "$1" >&2; exit 1; }
WARNINGS=0

CHECK_ONLY=false
case "${1:-}" in
  --check) CHECK_ONLY=true; info "Check mode: read-only validation" ;;
  "") ;;
  *) fail "Unknown argument: $1 (use --check or nothing)" ;;
esac

# version_ge A B → true if A >= B (dotted numeric)
version_ge() { [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)" == "$2" ]]; }

# --- 1. Prerequisites ---
info "Checking prerequisites..."
command -v git >/dev/null 2>&1 || fail "git not found"

# --check validates files only, so it runs without OpenCode (e.g. in CI).
if ! command -v "$OPENCODE_BIN" >/dev/null 2>&1; then
  if $CHECK_ONLY; then
    warn "OpenCode CLI not found — skipping version check (needed to run the team)"
  else
    fail "OpenCode CLI not found (set OPENCODE_BIN or install: https://opencode.ai/docs)"
  fi
else
  OPENCODE_VERSION="$("$OPENCODE_BIN" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
  if [[ -z "$OPENCODE_VERSION" ]]; then
    warn "Could not determine OpenCode version"
  elif version_ge "$OPENCODE_VERSION" "$MIN_OPENCODE_VERSION"; then
    ok "OpenCode $OPENCODE_VERSION"
  else
    fail "OpenCode $OPENCODE_VERSION is older than required $MIN_OPENCODE_VERSION"
  fi
fi

command -v uvx    >/dev/null 2>&1 || info "uvx not found — needed only if you enable team-atlassian"
command -v docker >/dev/null 2>&1 || info "docker not found — needed only if you enable team-github"

# --- 2. Skill repos (pinned) ---
info "Skill repos (superpowers loads via the plugin in opencode.json)..."
for entry in "${SKILL_REPOS[@]}"; do
  IFS='|' read -r name url sha <<<"$entry"
  dir="$SKILLS_DIR/$name"
  if [[ -d "$dir/.git" ]]; then
    current="$(git -C "$dir" rev-parse HEAD)"
    if [[ "$current" == "$sha" ]]; then
      ok "$name at pinned ${sha:0:12}"
    elif $CHECK_ONLY; then
      fail "$name at ${current:0:12}, expected ${sha:0:12} (run ./setup.sh)"
    else
      info "Moving $name to pinned ${sha:0:12}..."
      git -C "$dir" cat-file -e "${sha}^{commit}" 2>/dev/null || git -C "$dir" fetch --quiet origin "$sha"
      git -C "$dir" -c advice.detachedHead=false checkout --quiet "$sha"
      ok "$name at pinned ${sha:0:12}"
    fi
  elif $CHECK_ONLY; then
    fail "$name not installed (run ./setup.sh)"
  else
    info "Cloning $name..."
    mkdir -p "$SKILLS_DIR"
    git clone --quiet "$url" "$dir"
    git -C "$dir" -c advice.detachedHead=false checkout --quiet "$sha"
    ok "$name cloned at ${sha:0:12}"
  fi
done

# --- 3. Required skills are present and discoverable ---
info "Checking required skills..."
for entry in "${REQUIRED_SKILLS[@]}"; do
  IFS='|' read -r skill rel <<<"$entry"
  f="$SKILLS_DIR/$rel/SKILL.md"
  [[ -f "$f" ]] || fail "Required skill '$skill' not found at $f (run ./setup.sh)"
  # OpenCode requires the frontmatter name to match the skill's directory name
  grep -qE "^name:[[:space:]]*['\"]?${skill}['\"]?[[:space:]]*$" "$f" \
    || fail "Skill '$skill' at $f has a mismatched 'name:' in its frontmatter"
done
ok "Required skills present (${#REQUIRED_SKILLS[@]})"

# --- 4. Static validation ---
info "Validating files..."
command -v jq >/dev/null 2>&1 || fail "jq is required for validation (install jq)"

for sp in "${REQUIRED_SKILL_PATHS[@]}"; do
  jq -e --arg p "$sp" '(.skills.paths // []) | index($p)' opencode.json >/dev/null \
    || fail "opencode.json skills.paths must include $sp"
done
ok "opencode.json skills.paths point at the cloned skill repos"

jq -e '.mcp | to_entries | map(select(.key | startswith("team-"))) | all(.value.enabled == false)' opencode.json >/dev/null \
  || fail "team-* MCP servers in opencode.json must ship with \"enabled\": false"
ok "team-* MCP servers disabled by default"

# Tracked + untracked-but-not-ignored JSON (falls back to find outside a git checkout)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  json_files="$(git ls-files --cached --others --exclude-standard '*.json')"
else
  json_files="$(find opencode.json samples -name '*.json' -type f)"
fi
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  if jq empty "$f" >/dev/null 2>&1; then ok "valid JSON: $f"; else fail "invalid JSON: $f"; fi
done <<<"$json_files"

# Sample sprint must respect the 80% capacity rule
if [[ -f samples/sprint-state.json ]]; then
  if jq -e '(.stories | map(.points) | add) <= .capacity_points
            and .capacity_points == ((.team_velocity * 0.8) | floor)' samples/sprint-state.json >/dev/null; then
    ok "samples/sprint-state.json within capacity"
  else
    fail "samples/sprint-state.json exceeds capacity_points or capacity_points != floor(0.8 × velocity)"
  fi
fi

for agent in project-manager scrum-master developer tester progress-reporter; do
  f=".opencode/agents/$agent.md"
  [[ -f "$f" ]] || fail "Agent file missing: $f"
  if grep -q '^model:' "$f"; then warn "$f hardcodes a model — remove the model: line"; fi
  if [[ "$agent" != "project-manager" ]] && ! grep -q '^  task: "deny"' "$f"; then
    fail "$f must set task: \"deny\" (only the project-manager delegates)"
  fi
done
ok "Agent files present; only project-manager can delegate"

for cmd in doc-mode qna-mode; do
  grep -q '^agent: project-manager' ".opencode/commands/$cmd.md" \
    || fail ".opencode/commands/$cmd.md must run as agent: project-manager"
done
ok "Slash commands route to project-manager"

# --- 5. Resolved OpenCode config ---
# Install mode only: running OpenCode can fetch and cache the pinned plugin,
# which would break --check's read-only guarantee.
if ! $CHECK_ONLY; then
  info "Resolving OpenCode config (global + project)..."
  # Write to a file: OpenCode truncates large output at 64 KiB when stdout is a pipe.
  resolved="$(mktemp)"
  trap 'rm -f "$resolved"' EXIT
  "$OPENCODE_BIN" debug config >"$resolved" 2>/dev/null && jq empty "$resolved" 2>/dev/null \
    || fail "'$OPENCODE_BIN debug config' failed — opencode.json (or your global config) does not load"
  ok "opencode.json loads"

  for sp in "${REQUIRED_SKILL_PATHS[@]}"; do
    jq -e --arg p "$sp" '(.skills.paths // []) | any(endswith($p))' "$resolved" >/dev/null \
      || fail "Resolved config is missing skills path $sp"
  done
  ok "Skill paths registered with OpenCode"

  for srv in team-atlassian team-github team-copilot; do
    state="$(jq -r --arg s "$srv" 'if .mcp[$s] then (.mcp[$s].enabled | tostring) else "missing" end' "$resolved")"
    if [[ "$state" == "missing" ]]; then warn "MCP $srv missing from resolved config"; else info "MCP $srv: enabled=$state"; fi
  done
  others="$(jq -r '.mcp // {} | to_entries | map(select((.key | startswith("team-") | not) and .value.enabled != false) | .key) | join(", ")' "$resolved")"
  if [[ -n "$others" ]]; then info "Your own enabled MCP servers (the team can use these too): $others"; fi
fi

# --- 6. Summary ---
echo
if (( WARNINGS > 0 )); then
  printf "${YELLOW}═══ Done with %d warning(s) ═══${NC}\n" "$WARNINGS"
else
  printf "${GREEN}═══ Setup OK ═══${NC}\n"
fi
cat <<'EOF'

MCP servers in opencode.json are disabled by default. To enable one for a
session without editing the shared config:

  OPENCODE_CONFIG_CONTENT='{"mcp":{"team-atlassian":{"enabled":true}}}' \
    opencode --agent project-manager

Required environment variables:
  team-atlassian : JIRA_URL JIRA_USERNAME JIRA_API_TOKEN
                   CONFLUENCE_URL CONFLUENCE_USERNAME CONFLUENCE_API_TOKEN
  team-github    : GITHUB_PERSONAL_ACCESS_TOKEN (+ GITHUB_HOST for GitHub Enterprise)
  team-copilot   : none — run: opencode mcp auth team-copilot

Start:
  Doc Mode : write src/project-doc.md (from src/project-template.md), then
             opencode --agent project-manager   and type  /doc-mode
             or: opencode run --command doc-mode
  QnA Mode : opencode --agent project-manager   and type  /qna-mode
EOF
