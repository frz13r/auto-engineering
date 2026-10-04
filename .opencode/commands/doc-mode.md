---
description: Start the team from the project document in src/project-doc.md
agent: project-manager
---

Run **Doc Mode**.

Project document:

@src/project-doc.md

If the document above is missing or is still the unfilled template, stop and
ask the user to fill in `src/project-doc.md` instead of inventing context.

Otherwise follow your workflow from step 2: detect capabilities, write `context.md` per the
contract in `AGENTS.md`, delegate planning to `scrum-master`, then run the
develop → verify → report loop until every story is `done` or `blocked`.

Additional instructions from the user (may be empty): $ARGUMENTS
