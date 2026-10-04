---
name: autonomous-engineering-team
description: "OpenCode multi-agent team (PM orchestrator, Scrum Master, Developer, Tester, Progress Reporter) that plans sprints and delivers tested code in per-story git worktrees. Uses Superpowers, Matt Pocock and Karpathy skills. Optional Jira/Confluence/GitHub/Copilot MCP. No model hardcoded."
version: 2.1.0
license: MIT
platforms: [linux, macos]
---

# Autonomous Engineering Team

Use this to provision an OpenCode multi-agent team that takes a project from a
document (Doc Mode) or an interview (QnA Mode) to sprint planning, implementation,
independent testing, merging, and executive reporting.

## Setup

```bash
git clone <repo-url> auto-engineering
cd auto-engineering
./setup.sh
```

`setup.sh` clones the pinned Matt Pocock and Karpathy skill repos into
`.opencode/skills/` (registered in `opencode.json` via `skills.paths`) and
validates the configuration; `./setup.sh --check` is a read-only re-check. Superpowers is loaded by
the pinned plugin in `opencode.json`.

## Run

- Doc Mode: fill `src/project-doc.md` from `src/project-template.md`, then
  `opencode --agent project-manager` → `/doc-mode`
- QnA Mode: `opencode --agent project-manager` → `/qna-mode`

## Where things are defined

| What | File |
|---|---|
| Team contracts (handoff files, schemas, worktree rules, MCP) | `AGENTS.md` |
| Agent prompts and permissions | `.opencode/agents/*.md` |
| Plugin, opt-in MCP servers, default permissions | `opencode.json` |
| MCP setup | `docs/setup-guide.md` |
| Flow | `workflows/README.md` |
| Example artifacts | `samples/` |
