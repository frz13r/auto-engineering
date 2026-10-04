# AGENTS.md — Autonomous Engineering Team

Project-level instructions for the multi-agent engineering team. This file is
loaded by OpenCode at session start for all agents. Teammate-specific
instructions live in the individual agent files under `.opencode/agents/`.

## Team Structure

| Agent | Role | Mode | Delegates? |
|-------|------|------|------------|
| project-manager | EM + PM (orchestrator) | primary | YES — launches all subagents |
| scrum-master | Sprint planning | subagent | NO |
| developer | Implementation | subagent | NO |
| tester | QA / verification | subagent | NO |
| progress-reporter | Executive reporting | subagent | NO |

Only the Project Manager delegates. All other agents write results to files and report via stdout.

## Skills

This project bundles three open-source skill repositories:

| Repo | Loading Method | Highlights |
||------|---------------|------------|
|| obra/superpowers | Superpowers plugin (auto-registers at startup) | brainstorming, test-driven-development, systematic-debugging, verification-before-completion, writing-plans, dispatching-parallel-agents, finishing-a-development-branch |
|| mattpocock/skills | skills.paths in opencode.json | tdd, implement, implement-spec, diagnosing-bugs, code-review, grilling, grill-with-docs, to-tickets, codebase-design |
|| andrej-karpathy-skills | skills.paths in opencode.json | karpathy-guidelines (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution)

To invoke a skill: `use skill tool to load <skill-name>`
To list all skills: `use skill tool to list skills`

## Skill-to-Agent Mapping

| Skill | Used By | When |
|-------|---------|------|
| brainstorming (superpowers) | PM, Scrum Master | Before designing epics/stories |
| writing-plans (superpowers) | PM, Scrum Master, Reporter | Before drafting plans/reports |
| dispatching-parallel-agents (superpowers) | PM | Launching multiple Developers |
| test-driven-development (superpowers) | Developer | Before writing implementation |
| systematic-debugging (superpowers) | Developer, Tester | When encountering failures |
| verification-before-completion (superpowers) | Developer, Tester | Before claiming work done |
| finishing-a-development-branch (superpowers) | Developer | When all tests pass |
| karpathy-guidelines | ALL | General coding philosophy |
| tdd (mattpocock) | Developer | TDD workflow |
| implement / implement-spec (mattpocock) | Developer | Structured implementation |
| diagnosing-bugs (mattpocock) | Developer | Bug investigation |
| code-review (mattpocock) | Developer, Tester | Change review |
| grilling / grill-with-docs (mattpocock) | PM, Scrum Master | Interrogate specs |
| to-tickets (mattpocock) | PM | Break plans into tickets |

## File Handoff Protocol

All inter-agent communication happens through files in the project root:

| File | Produced By | Read By | Purpose |
|------|-------------|---------|---------|
| `context.md` | Project Manager | All agents | Project context, tech stack, MCP status, team capacity |
| `sprint-plan.md` | Scrum Master | Developer, Tester | Epics, stories, acceptance criteria |
| `sprint-state.json` | Scrum Master | PM, Reporter | Machine-readable sprint state |
| `dev-outputs/<STORY>.json` | Developer | Tester, PM | Implementation results |
| `test-outputs/<STORY>.json` | Tester | PM | Verification results |
| `progress-reports/<date>.md` | Reporter | PM, human | Executive summary |

## Entry Points

1. **Doc Mode** — Provide a project doc at `src/project-doc.md`, then:
   ```bash
   opencode run --agent project-manager \
     "Read src/project-doc.md. Extract context, check MCP availability,
      write context.md with mcp_status flags, then delegate to scrum-master."
   ```

2. **QnA Mode** — No project doc; the PM asks questions to understand the project:
   ```bash
   opencode run --agent project-manager \
     "You are in qna-mode. Ask 5-7 targeted questions, check MCP availability,
      gather MCP context, write context.md with mcp_status flags, then delegate to scrum-master."
   ```

## MCP Servers (all disabled by default — enable as needed)

| Server | Purpose | Env Var |
|--------|---------|---------|
| copilot-enterprise | MS Copilot Enterprise / Microsoft Graph | COPILOT_ENTERPRISE_URL |
| atlassian | Jira + Confluence | (MCP-remote auth) |
| github-enterprise | GitHub repos, PRs, issues | GITHUB_TOKEN |
| filesystem | Project-scoped file access | (always on) |

## No Model Is Hardcoded

All agent definitions omit the `model` field. OpenCode uses:
1. The `--model` flag if provided on the command line
2. The user's `model` setting in their global OpenCode config
3. The OpenCode interactive model picker

This means teammates can use any model they prefer — Claude, GPT, Llama, etc.
