---
project_name: TaskFlow Pro
repo_url: https://github.com/example/taskflow-pro
local_repo: /path/to/auto-engineering/workspace/taskflow-pro
default_branch: main
test_command: npm test
developers: 2
velocity: 20
sprint_length_days: 10
capabilities:
  jira: unavailable
  confluence: unavailable
  github: unavailable
  copilot: unavailable
---

# Project Context: TaskFlow Pro

## Capability Detection
No Jira, Confluence, GitHub or Copilot tools were present in the PM's session, so
the project document was the only context source. Planning is local, and
developers merge locally (no PRs).

## Overview
A web-based task management application with Scrum workflow support.

## Goals
- Kanban/Scrum task board with drag-and-drop
- User authentication with role-based access
- Real-time collaboration via WebSocket
- Export to CSV/PDF

## Out of Scope
- Mobile app (web-only for v1)
- Third-party integrations beyond GitHub sign-in

## Technical Details
| Field | Value |
|---|---|
| Language | TypeScript |
| Framework | Next.js 14 / React 18 |
| Hosting | Vercel |
| Database | Supabase (PostgreSQL) |

## Success Criteria
- [ ] Users can create and organise tasks on a board
- [ ] Drag-and-drop between columns
- [ ] JWT authentication with role-based access
- [ ] 90% test coverage
- [ ] Board loads in under 100 ms
