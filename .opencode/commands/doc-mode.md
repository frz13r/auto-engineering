# Doc Mode

Start from a project document at `src/project-doc.md`. The Project Manager gathers context and launches the team.

## Run

```bash
opencode run --agent project-manager \
  "Read src/project-doc.md. Extract project name, tech stack, team capacity,
   check MCP availability, write context.md with mcp_status flags, then delegate to scrum-master."
```

## Requirements

- Project description at `src/project-doc.md` (use `src/project-template.md` as starting point)
- OpenCode CLI with project-level config (opencode.json at repo root)

## Expected Output

- `context.md` — Project context with mcp_status flags
- `sprint-plan.md` — Epics, stories, sprint 1 plan
- `sprint-state.json` — Machine-readable sprint state
- `dev-outputs/*.json` — Implementation results per story
- `test-outputs/*.json` — Test/verification results per story
- `progress-reports/*.md` — Executive progress reports
