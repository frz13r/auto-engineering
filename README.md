# Autonomous Engineering Team

A multi-agent engineering team for the [OpenCode](https://opencode.ai) CLI. Five
agents take a project from context gathering, through sprint planning (Jira
optional), to tested, merged code and executive progress reports.

- **No model hardcoded** — uses your `--model` flag or default model.
- **Works offline from MCP** — Jira, Confluence, GitHub and Copilot are optional;
  without them the team plans locally and merges locally.
- **Safe parallelism** — each story gets its own git worktree and branch.

## Agents

| Agent | Role | Mode | Delegates |
|---|---|---|---|
| project-manager | Orchestrator: context, planning, worktrees, merges | primary | scrum-master, developer, tester, progress-reporter |
| scrum-master | Epics, stories, points, Sprint 1 within 80% capacity | subagent | — |
| developer | Implements one story in its worktree, test-first | subagent | — |
| tester | Independent verification; cannot edit code | subagent | — |
| progress-reporter | Short executive reports; read-only | subagent | — |

Only the project manager delegates. Subagents communicate through files (see
[`AGENTS.md`](AGENTS.md), the single source of truth for all contracts).

## Quick Start

```bash
git clone <this-repo> auto-engineering
cd auto-engineering
./setup.sh            # installs pinned skill repos and validates the config
```

Then:

- **Doc Mode** — `cp src/project-template.md src/project-doc.md`, fill it in, then
  `opencode --agent project-manager` and type `/doc-mode`
  (or headless: `opencode run --command doc-mode`).
- **QnA Mode** — `opencode --agent project-manager` and type `/qna-mode`
  (TUI only; it asks you questions).

See [`workflows/README.md`](workflows/README.md) for the full flow.

## Skills

| Source | Loaded via | Used for |
|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | OpenCode plugin, pinned tag in `opencode.json` | brainstorming, TDD, debugging, verification, plans, parallel agents, git worktrees |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Cloned by `setup.sh` (pinned commit) into `.opencode/skills/` | tdd, implement, implement-spec, diagnosing-bugs, code-review, grilling, grill-with-docs, ask-matt, to-tickets |
| [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | Cloned by `setup.sh` (pinned commit) into `.opencode/skills/` | karpathy-guidelines |

OpenCode discovers skills under `.opencode/skills/` automatically. To upgrade a
skill source, change its pinned commit/tag in `setup.sh` / `opencode.json`.

## MCP Servers (optional, all disabled by default)

| Server | Provides | Needs |
|---|---|---|
| team-atlassian | Jira + Confluence | `uvx`, `JIRA_*` / `CONFLUENCE_*` env vars |
| team-github | GitHub / GitHub Enterprise | Docker, `GITHUB_PERSONAL_ACCESS_TOKEN` (+ `GITHUB_HOST`) |
| team-copilot | Microsoft 365 Copilot Enterprise | `opencode mcp auth team-copilot` |

Already have Jira/GitHub MCP servers in your global OpenCode config? Keep them —
the team detects capabilities from the tools it has, whatever the server is
called. Otherwise enable the `team-*` servers just for yourself; see
[`docs/setup-guide.md`](docs/setup-guide.md).

## File Handoffs (gitignored run artifacts)

| File | Written by |
|---|---|
| `context.md` | project-manager |
| `sprint-plan.md` | scrum-master |
| `sprint-state.json` | scrum-master (creates), project-manager (updates) |
| `dev-outputs/<ID>.json` | developer |
| `test-outputs/<ID>.json` | tester |
| `progress-reports/*.md` | progress-reporter |
| `.worktrees/<ID>/` | project-manager (one per in-flight story) |

## Project Structure

```
.
├── opencode.json            # Plugin + opt-in MCP servers + default permissions
├── AGENTS.md                # Team contracts (loaded for every agent)
├── setup.sh                 # Install pinned skills + validate (./setup.sh --check)
├── .opencode/
│   ├── agents/              # 5 agent definitions (prompt + permissions)
│   ├── commands/            # /doc-mode, /qna-mode
│   └── skills/              # Cloned by setup.sh (gitignored)
├── src/project-template.md  # Start here for Doc Mode
├── docs/setup-guide.md      # MCP setup
├── workflows/README.md      # Flow details
└── samples/                 # Example artifacts from a simulated sprint
```

## Samples

- `example-project-doc.md` — a filled-in Doc Mode input (Blog Posts API, a real
  open-source Flask repo).
- The rest show a simulated sprint for a fictional "TaskFlow Pro" app:
  `example-context.md`, `sprint-plan.md`, `sprint-state.json`,
  `dev-outputs/AUTH-101.json`, `test-outputs/AUTH-101.json`, and
  `progress-reports/sprint-1-2025-01-20.md`.
