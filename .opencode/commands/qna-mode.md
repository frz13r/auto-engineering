# QnA Mode

Interactive project discovery — the Project Manager asks questions to understand your project, then launches the team.

## Run

```bash
opencode run --agent project-manager \
  "You are in qna-mode. Ask 5-7 targeted questions about the project (goals,
   audience, tech constraints, scope, success criteria). Based on the answers,
   check MCP availability, gather context, write context.md with mcp_status flags,
   then delegate to scrum-master."
```

## What the PM Asks

1. **Project Goal** — What are you building?
2. **Target Audience** — Who uses it?
3. **Tech Stack** — Preferred language/framework?
4. **Scope** — How big is this? (~5 stories? 50?)
5. **Existing Repo** — GitHub URL or local path?
6. **Success Criteria** — What does "done" look like?
7. **Team Capacity** — How many developers? Velocity? Sprint length?

## After QnA

The PM writes `context.md` and transitions to the same flow as Doc Mode: delegates to Scrum Master, launches Developers, Testers, and Progress Reporters until all stories are complete.
