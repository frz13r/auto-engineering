# AGENTS.md — Autonomous Engineering Team

Project-level instructions for the multi-agent engineering team. OpenCode loads
this file for every agent. Role-specific instructions live in
`.opencode/agents/<agent>.md`. **This file is the single source of truth for the
handoff contracts below** — agent files refer to it rather than redefining them.

## Team Structure

| Agent | Role | Mode | Delegates? |
|-------|------|------|------------|
| project-manager | EM + PM (orchestrator) | primary | YES — the only agent that launches subagents |
| scrum-master | Sprint planning | subagent | NO |
| developer | Implementation | subagent | NO |
| tester | QA / verification | subagent | NO |
| progress-reporter | Executive reporting | subagent | NO |

Only the Project Manager delegates (via OpenCode's `task` tool). All other
agents write results to files and report a short summary in their final message.

## Skills

| Source | Loading method | Highlights |
|--------|----------------|------------|
| obra/superpowers | OpenCode plugin, pinned in `opencode.json` | brainstorming, test-driven-development, systematic-debugging, verification-before-completion, writing-plans, dispatching-parallel-agents, finishing-a-development-branch, using-git-worktrees |
| mattpocock/skills | Cloned by `setup.sh` (pinned commit), registered via `skills.paths` | tdd, implement, implement-spec, diagnosing-bugs, code-review, grilling, grill-with-docs, ask-matt, to-tickets, codebase-design |
| andrej-karpathy-skills | Cloned by `setup.sh` (pinned commit), registered via `skills.paths` | karpathy-guidelines (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) |

Load a skill with the `skill` tool, e.g. `skill(name: "tdd")`.

## Skill-to-Agent Mapping

| Skill | Used By | When |
|-------|---------|------|
| brainstorming (superpowers) | PM, Scrum Master | Before designing epics/stories |
| writing-plans (superpowers) | PM, Scrum Master, Reporter | Before drafting plans/reports |
| dispatching-parallel-agents (superpowers) | PM | Launching multiple Developers |
| test-driven-development (superpowers) | Developer | Before writing implementation |
| systematic-debugging (superpowers) | Developer, Tester | When encountering failures |
| verification-before-completion (superpowers) | Developer, Tester | Before claiming work done |
| karpathy-guidelines | ALL | General coding philosophy |
| tdd (mattpocock) | Developer | TDD workflow |
| implement / implement-spec (mattpocock) | Developer | Structured implementation |
| diagnosing-bugs (mattpocock) | Developer | Bug investigation |
| code-review (mattpocock) | Developer, Tester | Change review |
| grilling / grill-with-docs / ask-matt (mattpocock) | PM, Scrum Master | Interrogate specs |
| to-tickets (mattpocock) | PM | Break plans into tickets |

## File Handoff Protocol

All inter-agent communication happens through files in the project root. These
are run artifacts and are gitignored.

| File | Written By | Read By | Purpose |
|------|------------|---------|---------|
| `context.md` | Project Manager | All agents | Project context, repo, capabilities, team capacity |
| `sprint-plan.md` | Scrum Master | Developer, Tester | Epics, stories, acceptance criteria |
| `sprint-state.json` | Scrum Master (creates), **Project Manager (sole writer afterwards)** | PM, Reporter | Machine-readable sprint state |
| `dev-outputs/<STORY>.json` | Developer | Tester, PM | Implementation results |
| `test-outputs/<STORY>.json` | Tester | PM | Verification results |
| `progress-reports/sprint-<N>-<YYYY-MM-DD>.md` | Reporter | PM, human | Executive summary |

### `context.md` contract

Must begin with YAML front matter using exactly these keys (agents parse them):

```yaml
---
project_name: Blog Posts API
repo_url: https://github.com/org/repo   # or null
local_repo: /abs/path/to/project_root/workspace/blog-api   # always the team's own repo
default_branch: main
test_command: pytest tests/ -v          # required before development starts
developers: 2
velocity: 20                            # points per sprint
sprint_length_days: 10
capabilities:
  jira: unavailable                     # available | unavailable
  confluence: unavailable
  github: unavailable
  copilot: unavailable
---
```

Free-form Markdown (goals, scope, constraints, findings) follows the front matter.

### `sprint-state.json` schema

```json
{
  "sprint_number": 1,
  "sprint_goal": "Build user authentication module",
  "start_date": "2025-01-15",
  "end_date": "2025-01-29",
  "team_velocity": 20,
  "capacity_points": 16,
  "max_concurrent_devs": 2,
  "stories": [
    {
      "id": "AUTH-101",
      "title": "Implement login endpoint",
      "epic": "Authentication",
      "points": 5,
      "status": "todo",
      "dependencies": [],
      "assignee": null,
      "branch": null,
      "pr": null,
      "test_result": null,
      "attempts": 0,
      "notes": ""
    }
  ]
}
```

- `status`: `todo` → `in_progress` → `in_review` → `tested` → `done`, or `blocked`
- `test_result`: `null` | `"APPROVE"` | `"REQUEST_CHANGES"`
- `capacity_points` = floor(0.8 × `team_velocity`); the sum of story points must not exceed it
- `max_concurrent_devs` ≤ `developers` in `context.md`

### `dev-outputs/<ID>.json` schema

```json
{
  "story_id": "AUTH-101",
  "story_title": "Implement login endpoint",
  "status": "complete",
  "branch": "story/AUTH-101",
  "worktree": "/abs/project_root/.worktrees/AUTH-101",
  "commit_hash": "abc1234",
  "files_created": ["src/auth/login.py"],
  "files_modified": ["src/app.py"],
  "tests_passed": true,
  "tests_count": 12,
  "tests_failed": 0,
  "pr_url": null,
  "notes": ""
}
```

`status`: `complete` | `failed` (reason in `notes`).

### `test-outputs/<ID>.json` schema

```json
{
  "story_id": "AUTH-101",
  "verdict": "APPROVE",
  "commit_tested": "abc1234",
  "acceptance_criteria": [
    {"criterion": "...", "status": "met", "notes": "tests/test_login.py::test_ok"}
  ],
  "tests_run": 12,
  "tests_passed": 12,
  "tests_failed": 0,
  "issues_found": [],
  "summary": "All acceptance criteria met."
}
```

`verdict`: `APPROVE` | `REQUEST_CHANGES`. Each `issues_found` entry says what is
wrong, where, and what "fixed" looks like.

## Team Repo

The team never works in the user's own checkout. The PM creates the team's repo
at `<project_root>/workspace/<name>` (a clone of the given repo, or `git init` for
greenfield) and records it as `local_repo`. Everything — repo, worktrees, run
artifacts — stays inside the project root, so no agent needs
`external_directory` access.

## Parallel Development Rules

Parallel developers must never share a working tree.

- The PM creates one git worktree per story, under this project's gitignored
  `.worktrees/` directory (so agents never need access outside the project):
  `git -C <local_repo> worktree add <project_root>/.worktrees/<STORY-ID> -b story/<STORY-ID> <default_branch>`
- Developers work **only** inside their assigned worktree and commit only there,
  staging files explicitly by path. Never `git add -A`, `git commit -a`,
  `git stash`, `git checkout`/`switch`, `git reset --hard`, or `git push --force`.
- Testers verify inside the same worktree and do not modify it.
- After APPROVE, the PM merges `story/<STORY-ID>` into `default_branch` inside
  `local_repo` (one story at a time), runs `test_command`, and commits the merge
  only if the tests pass; then it removes the worktree.
- Worktrees are gitignored, so search tools skip them by default: developers and
  testers pass their worktree as the explicit `path` to `glob` / `grep`.
- A fresh worktree has no installed dependencies (`node_modules`, `.venv`, ...);
  install them inside the worktree before running `test_command`.
- The bash deny rules in the agent files are defense-in-depth. Worktree
  isolation is the real safeguard; agents must follow these rules regardless.

## Entry Points

- **Doc Mode** — write `src/project-doc.md` (start from `src/project-template.md`), then
  run `/doc-mode` in the TUI, or `opencode run --command doc-mode`.
- **QnA Mode** — start the TUI with `opencode --agent project-manager` and run `/qna-mode`.
  QnA needs the interactive TUI because `opencode run` cannot answer questions.

## MCP Servers (all disabled by default)

`opencode.json` ships three opt-in servers, prefixed `team-` so they never
collide with servers you already have in your global config.

| Server | Provides | Requirements |
|--------|----------|--------------|
| team-atlassian | Jira + Confluence (`mcp-atlassian`) | `uvx`; `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN`, `CONFLUENCE_URL`, `CONFLUENCE_USERNAME`, `CONFLUENCE_API_TOKEN` |
| team-github | GitHub / GitHub Enterprise (`github-mcp-server`) | Docker; `GITHUB_PERSONAL_ACCESS_TOKEN`, optional `GITHUB_HOST` for GHE |
| team-copilot | Microsoft 365 Copilot Enterprise | OAuth: `opencode mcp auth team-copilot` |

The PM detects capabilities by **tools actually available in its session**, not
by server name — so a teammate's own globally configured Jira/GitHub servers
count too. See `docs/setup-guide.md`.

## No Model Is Hardcoded

Agent definitions omit the `model` field. OpenCode uses the `--model` flag, else
the user's configured default model, else the interactive picker.
