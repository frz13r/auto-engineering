# Workflows

## Doc Mode — Start from a Project Document

Use this when the user has a written project description.

### Input

Place your project description at `src/project-doc.md`. Use the template at `src/project-template.md`.

### Run

```bash
opencode run --agent project-manager \
  "Read src/project-doc.md. Extract project name, tech stack, team capacity,
   check MCP availability, write context.md with mcp_status flags, then delegate to scrum-master."
```

### What Happens

1. **Project Manager** reads the project doc, checks which MCP servers are available
2. Writes `context.md` with project context and `mcp_status` flags
3. Delegates to **Scrum Master** with the instruction to plan sprints
4. **Scrum Master** creates epics/stories (in Jira if available, otherwise local), packs Sprint 1, writes `sprint-plan.md` and `sprint-state.json`
5. **Project Manager** launches **Developers** in parallel for independent stories
6. **Project Manager** launches **Tester** for each story
7. **Project Manager** launches **Progress Reporter** for executive summaries
8. The PM continues the full dev-test-report loop until all stories are done

### Expected Output

- `context.md` — extracted project context
- `sprint-plan.md` — epics, stories, sprint 1 plan
- `sprint-state.json` — machine-readable sprint state
- `dev-outputs/<STORY>.json` — implementation results per story
- `test-outputs/<STORY>.json` — test/verification results per story
- `progress-reports/<date>.md` — executive progress reports

---

## QnA Mode — Interactive Project Discovery

Use this when there is no project document — the PM asks questions to understand the project.

### Run

```bash
opencode run --agent project-manager \
  "You are in qna-mode. Ask 5-7 targeted questions about the project (goals,
   audience, tech constraints, scope, success criteria). Based on the answers,
   check MCP availability, gather context, write context.md with mcp_status flags,
   then delegate to scrum-master."
```

### Questions the PM Will Ask

1. **Project Goal** — What are you building? (one sentence)
2. **Target Audience** — Who uses it? (internal team, public users, etc.)
3. **Tech Stack** — Preferred language/framework? (TypeScript/React, Python/FastAPI, Go, etc.)
4. **Scope** — How big is this? (~5 stories? 50 stories? Multi-sprint?)
5. **Existing Repo** — Is there a codebase? (GitHub URL or local path)
6. **Success Criteria** — What does "done" look like? (tests passing, deployed, etc.)
7. **Team Capacity** — How many developers? Velocity? Sprint length?

### What Happens Next

After gathering answers, the PM transitions to the same doc-mode flow: writes `context.md`, delegates to Scrum Master, and the full sprint cycle begins.

---

## Progress Reporting

Progress reports are generated automatically at sprint milestones. To manually request one:

```bash
opencode run --agent project-manager \
  "Launch progress-reporter to generate an executive summary from sprint-state.json."
```

Reports are written to `progress-reports/` and follow the format:

```
[Project Name] — Sprint 1, Day 2 of 10
Progress: ████████░░ 60%

Completed:
- AUTH-101: Implement login endpoint ✅

In Progress:
- AUTH-102: JWT token service 🚧

Blocked:
- (none)

**Executive Summary:** ...
```
