---
description: Start the team by interviewing the user about the project
agent: project-manager
---

Run **QnA Mode**.

Use the `question` tool to ask 5–7 targeted questions, batching them where you can:

1. Goal — what are we building?
2. Audience — who uses it?
3. Tech stack — language / framework / database?
4. Scope — roughly how many stories; what is out of scope?
5. Existing repo — URL or local path, default branch, test command?
6. Success criteria — what does "done" look like?
7. Team capacity — developers, velocity, sprint length?

Then follow your workflow from step 2: detect capabilities, write `context.md`
per the contract in `AGENTS.md`, delegate planning to `scrum-master`, and run the
develop → verify → report loop until every story is `done` or `blocked`.

Additional context from the user (may be empty): $ARGUMENTS
