# Workflows

Contracts (file formats, `sprint-state.json` schema, worktree rules) live in
[`AGENTS.md`](../AGENTS.md). This page describes the flow.

## Doc Mode — start from a project document

1. Copy `src/project-template.md` to `src/project-doc.md` and fill it in
   (`samples/example-project-doc.md` is a worked example).
2. Run it:
   - TUI: `opencode --agent project-manager`, then type `/doc-mode`
   - Headless: `opencode run --command doc-mode`

Headless runs can't answer permission prompts. The agents' own permissions cover
normal work, but anything that would ask is rejected; add `--auto` only if you
accept auto-approving every non-denied action.

## QnA Mode — interactive discovery

`opencode --agent project-manager`, then type `/qna-mode`. The PM asks 5–7
questions with the `question` tool. This needs the TUI — `opencode run` cannot
answer questions.

## What happens

```
Doc / QnA
  → PM: detect capabilities from available tools
        clone / init the team repo at workspace/<name> → context.md
  → scrum-master: epics, stories, Sprint 1 within 80% capacity
                  → sprint-plan.md + sprint-state.json
  → PM loop, per ready story (up to max_concurrent_devs at once):
      create worktree .worktrees/<ID> on branch story/<ID>
      developer (in worktree)  → dev-outputs/<ID>.json
      tester    (in worktree)  → test-outputs/<ID>.json
      APPROVE         → PM merges (--no-commit), runs tests, commits or aborts, removes worktree
      REQUEST_CHANGES → back to developer (max 3 attempts, then blocked)
  → progress-reporter after planning, each batch, and sprint end
                  → progress-reports/sprint-<N>-<date>.md
  → stop when every story is done or blocked
```

The PM is the only agent that updates `sprint-state.json` after it is created.

## Ad-hoc progress report

```bash
opencode run --agent project-manager "Delegate to progress-reporter for a report on the current sprint."
```

## Reset between runs

Run artifacts are gitignored. To start fresh (removes the team's worktrees and
`story/*` branches in its own repo under `workspace/`, never your checkout):

```bash
LOCAL_REPO=workspace/<name>
rm -rf .worktrees context.md sprint-plan.md sprint-state.json dev-outputs test-outputs progress-reports
git -C "$LOCAL_REPO" worktree prune
git -C "$LOCAL_REPO" for-each-ref --format='%(refname:short)' 'refs/heads/story/*' |
  while IFS= read -r branch; do
    [ -n "$branch" ] && git -C "$LOCAL_REPO" branch -D "$branch"
  done
```

Or delete `workspace/` too, to re-clone from scratch.
