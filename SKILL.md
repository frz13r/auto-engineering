---
name: autonomous-engineering-team
description: "OpenCode multi-agent team: EM+PM, Scrum Master, Developers, Tester, Progress Reporter. Bundled Superpowers (15 skills via plugin), Matt Pocock (37 skills), and Karpathy guidelines. Portable single-command setup. No model hardcoded."
version: 2.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [multi-agent, opencode, engineering-team, mcp, autonomous, e2e-delivery, jira, scrum, superpowers, skills]
---

# Autonomous Engineering Team v2

A portable multi-agent engineering system built on OpenCode CLI spanning three stages: context gathering, Jira sprint planning, and development delivery. Features bundled open-source skills (53 + 1 built-in), no hardcoded model, and a one-command setup script for teammates.

## When to Use

Use this skill when you need to provision an autonomous multi-agent engineering team that can take a project from initial concept through Jira sprint planning to code delivery and executive reporting, using OpenCode CLI with MCP servers.

## Five Specialized Agents

| Agent | Role | Mode | Delegates To |
|---|---|---|---|
| **Project Manager (EM+PM)** | Orchestrator: context, planning, coordination | primary | 4 subagents |
| **Scrum Master** | Jira sprint planning: epics, stories, points, capacity | subagent | (none — reports via files) |
| **Developer** | Implements sprint stories, writes tests | subagent | (none — reports via files) |
| **Tester** | Verifies acceptance criteria, runs tests | subagent | (none — reports via files) |
| **Progress Reporter** | Executive progress summaries | subagent | (none — reports via files) |

**Key design**: The Project Manager is the sole orchestrator. It fans out subagents in parallel and collects results via file-based handoffs. Subagents never delegate — they write results to files and exit.

## Two Entry Modes

1. **Doc Mode**: User provides a Markdown project document. PM reads it, gathers MCP context, proceeds.
2. **QnA Mode**: PM asks 5-7 targeted questions, then proceeds.

**Works without MCP servers**: Project Manager detects availability and writes `mcp_status: unavailable` flags. Falls back to local files if Jira/GitHub/Copilot unavailable.

## Portable Setup

```bash
git clone <repo-url>
cd autonomous-engineering-team/v1
./setup.sh
```

The `setup.sh` script:
- Clones Matt Pocock and Karpathy skills repos into `.opencode/skills/` (superpowers loads via plugin)
- Configures the Superpowers OpenCode plugin in `opencode.json`
- Verifies MCP server configuration
- Verifies all 5 agent files (model-free + skill instructions)

## OpenCode Config

This project is fully self-contained. No global config needed.

| Location | Purpose |
|---|---|
| `opencode.json` | Project-level config: MCP servers, agents, skills paths, Superpowers plugin |
| `.opencode/agents/*.md` | 5 agent system prompts (model-free) |
| `.opencode/skills/` | 2 skill repos (mattpocock, karpathy; superpowers via plugin) | 53 total skills |
| `.opencode/commands/*.md` | OpenCode slash commands (doc-mode, qna-mode) |
| `AGENTS.md` | Team-wide instructions + skill-to-agent mapping |

## Bundled Skills (53 skills + 1 built-in)

### obra/superpowers (15 skills)
Plugin auto-registers and injects bootstrap context. Key skills:
- brainstorming, test-driven-development, systematic-debugging, verification-before-completion, writing-plans, dispatching-parallel-agents, finishing-a-development-branch

### mattpocock/skills (37 skills)
tdd, implement, implement-spec, diagnosing-bugs, code-review, grilling, grill-with-docs, to-tickets, codebase-design, research, and 20 more

### andrej-karpathy-skills (1 skill, 4 principles)
karpathy-guidelines: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution

## Skill-to-Agent Mapping

| Agent | Skills |
|---|---|
| **Project Manager** | brainstorming, writing-plans, dispatching-parallel-agents, karpathy-guidelines, grill-with-docs, to-tickets |
| **Scrum Master** | brainstorming, writing-plans, grilling, karpathy-guidelines |
| **Developer** | test-driven-development, systematic-debugging, verification-before-completion, finishing-a-development-branch, tdd, implement, diagnose-bugs, code-review, karpathy-guidelines |
| **Tester** | verification-before-completion, systematic-debugging, code-review, karpathy-guidelines |
| **Progress Reporter** | writing-plans, karpathy-guidelines |

## Usage

### Doc Mode
```bash
opencode run --agent project-manager \
  "Read src/project-doc.md. Extract project name, tech stack, team capacity,
   check MCP availability, write context.md with mcp_status flags,
   then delegate to scrum-master."
```

### QnA Mode
```bash
opencode run --agent project-manager \
  "You are in qna-mode. Ask 5-7 targeted questions, check MCP availability,
   gather MCP context, write context.md with mcp_status flags,
   then delegate to scrum-master."
```

## Project Structure

```
v1/
├── opencode.json              # Portable OpenCode config
├── AGENTS.md                  # Team-wide instructions + skill mapping
├── setup.sh                   # One-command teammate setup
├── README.md                  # Full documentation
├── SKILL.md                   # This file
├── .gitignore
├── .opencode/
│   ├── agents/                # 5 agent system prompts (model-free, active)
│   ├── skills/                # 2 skill repos (mattpocock, karpathy; superpowers via plugin)
│   └── commands/              # doc-mode.md, qna-mode.md
├── docs/
│   └── setup-guide.md         # MCP server setup
├── src/
│   └── project-template.md    # Template for project docs
├── workflows/
│   └── README.md              # Workflow docs
├── samples/                   # Example artifacts
├── dev-outputs/               # (gitignored)
├── test-outputs/              # (gitignored)
└── progress-reports/          # (gitignored)
```

## Sample Artifacts

See `samples/` for example outputs from a simulated sprint:
- `example-context.md` — sample context.md
- `sprint-plan.md` — sample sprint plan
- `sprint-state.json` — sample state file
- `dev-outputs/AUTH-101.json` — sample developer output
- `test-outputs/AUTH-101.json` — sample tester output
- `progress-reports/sprint-1-day-3.md` — sample executive report
