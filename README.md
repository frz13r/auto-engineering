# Autonomous Engineering Team — v2

A multi-agent engineering system on OpenCode CLI with 5 specialized agents spanning 3 stages: context gathering, Jira sprint planning, and development delivery — using MCP servers for Jira, Confluence, GitHub, and MS Copilot Enterprise.

**Fully portable** — no model hardcoded, skills bundled, single `setup.sh` to get working on any teammate's machine.

## Architecture

Five agents working as a coordinated team:

| Agent | Role | Mode | Delegates To |
|---|---|---|---|
| Project Manager (EM+PM) | Orchestrator: context, planning, coordination | primary | scrum-master, developer, tester, progress-reporter |
| Scrum Master | Jira sprint planning: epics, stories, points, capacity | subagent | (none — reports via files) |
| Developer | Implements sprint stories, writes tests | subagent | (none — reports via files) |
| Tester | Verifies acceptance criteria, runs tests | subagent | (none — reports via files) |
| Progress Reporter | Executive progress summaries | subagent | (none — reports via files) |

**Key design**: The Project Manager is the sole orchestrator. It fans out subagents in parallel and collects results via file-based handoffs (`dev-outputs/`, `test-outputs/`, `sprint-state.json`). Subagents never delegate — they write results to files and exit.

## Quick Start (Teammate Setup)

```bash
git clone <this-repo>
cd autonomous-engineering-team/v1
./setup.sh
```

The `setup.sh` script will:
1. Clone Matt Pocock and Karpathy skills repos (superpowers loads via plugin)
2. Configure the Superpowers OpenCode plugin
3. Verify MCP server configuration
4. Verify all 5 agent files and their skill instructions

Then start a session:
```bash
opencode  # OpenCode auto-loads opencode.json + AGENTS.md
```

**No model is hardcoded** — OpenCode uses your default model or `--model` flag. Every teammate can use Claude, GPT, or any model they prefer.

## Skills (3 sources, 53 skills + 1 built-in)

| Repo | Skills | Loading Method | Used By |
||------|--------|---------------|---------|
|| **obra/superpowers** (15 skills) | brainstorming, test-driven-development, systematic-debugging, verification-before-completion, writing-plans, dispatching-parallel-agents, finishing-a-development-branch | Superpowers plugin (auto-registers at startup) | PM, Developers, Tester |
|| **mattpocock/skills** (37 skills) | tdd, implement, implement-spec, diagnosing-bugs, code-review, grilling, grill-with-docs, to-tickets, codebase-design, research, and 20 more | skills.paths in opencode.json | PM, Developers, Tester |
|| **andrej-karpathy-skills** (1 skill, 4 principles) | karpathy-guidelines: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution | skills.paths in opencode.json | ALL agents |

Skills are auto-discovered from `.opencode/skills/`. The Superpowers plugin auto-registers its own skills directory at startup and injects bootstrap context so skills trigger at the right moments. Matt Pocock and Karpathy skills are loaded via the `skills.paths` config key.

## Entry Modes

### Doc Mode — Start from a Project Document

Place your project description at `src/project-doc.md` (use `src/project-template.md` as starting point), then:

```bash
opencode run --agent project-manager \
  "Read src/project-doc.md. Extract project name, tech stack, team capacity,
   check MCP availability, write context.md with mcp_status flags, then delegate to scrum-master."
```

### QnA Mode — Interactive Project Discovery

No project doc? The PM asks 5-7 questions to understand your project:

```bash
opencode run --agent project-manager \
  "You are in qna-mode. Ask 5-7 targeted questions about the project (goals,
   audience, tech constraints, scope, success criteria). Based on the answers,
   check MCP availability, gather context, write context.md with mcp_status flags,
   then delegate to scrum-master."
```

### How It Works

```
User Input (doc or QnA)
    ↓
Project Manager — checks MCP availability, gathers context → context.md
    ↓
Scrum Master — creates epics/stories, packs sprint → sprint-plan.md + sprint-state.json
    ↓
Project Manager (orchestrator) — launches Developers in parallel → dev-outputs/
    ↓
Project Manager — launches Testers → test-outputs/
    ↓
Progress Reporter → progress-reports/
```

## File Handoff Protocol

All inter-agent communication happens through files in the project root:

| File | Produced By | Purpose |
|------|-------------|---------|
| `context.md` | Project Manager | Project context, tech stack, MCP status, team capacity |
| `sprint-plan.md` | Scrum Master | Epics, stories, acceptance criteria |
| `sprint-state.json` | Scrum Master | Machine-readable sprint state |
| `dev-outputs/<STORY>.json` | Developer | Implementation results |
| `test-outputs/<STORY>.json` | Tester | Test/verification results |
| `progress-reports/<date>.md` | Reporter | Executive summary |

## MCP Servers (all disabled by default)

| Server | Purpose | Env Var |
|---|---|---|
| Copilot Enterprise | MS Copilot Enterprise / Microsoft Graph | COPILOT_ENTERPRISE_URL |
| Atlassian | Jira + Confluence (requires mcp-remote) | — |
| GitHub Enterprise | GitHub repos, PRs, issues | GITHUB_TOKEN |
| Filesystem | Project-scoped file access (always on) | — |

**Works without MCP**: If servers are unavailable, the Project Manager detects this and writes `mcp_status: unavailable` flags. The team falls back to local files.

## Project Structure

```
v1/
├── opencode.json              # Portable OpenCode config (agents, MCP, skills, plugin)
├── AGENTS.md                  # Team-wide instructions + skill mapping
├── setup.sh                   # Run once to install everything
├── README.md                  # This file
├── .gitignore
├── .opencode/
│   ├── agents/                # 5 agent system prompts (model-free, active)
│   │   ├── project-manager.md
│   │   ├── scrum-master.md
│   │   ├── developer.md
│   │   ├── tester.md
│   │   └── progress-reporter.md
│   ├── skills/                # 2 skill repos (mattpocock, karpathy; superpowers via plugin)
│   ├── commands/              # OpenCode slash commands
│   │   ├── doc-mode.md
│   │   └── qna-mode.md
├── src/
│   └── project-template.md    # Template for project docs
├── workflows/
│   └── README.md              # Workflow documentation
├── samples/                   # Example artifacts from a sim run
│   ├── example-context.md
│   ├── sprint-plan.md
│   ├── sprint-state.json
│   ├── dev-outputs/
│   ├── test-outputs/
│   └── progress-reports/
├── dev-outputs/               # (gitignored) developer outputs
├── test-outputs/              # (gitignored) tester outputs
└── progress-reports/          # (gitignored) executive reports
```

## Sample Artifacts

See the `samples/` directory for example outputs from a simulated sprint:
- `example-context.md` — what `context.md` looks like after context gathering
- `sprint-plan.md` — sample sprint plan with epics and stories
- `sprint-state.json` — sample machine-readable sprint state
- `dev-outputs/AUTH-101.json` — sample developer output
- `test-outputs/AUTH-101.json` — sample tester output
- `progress-reports/sprint-1-day-3.md` — sample executive report
