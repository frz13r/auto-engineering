---
project_name: TaskFlow Pro
version: 1.0
generated_by: project-manager agent (doc-mode)
---

# Project Context: TaskFlow Pro

## MCP Status
All MCP servers were unavailable during this example run. The Project Manager
used the project document (src/project-template.md) as the sole context source.

```yaml
mcp_status:
  copilot-enterprise: unavailable
  atlassian: unavailable
  github-enterprise: unavailable
```

## Project Overview

| Field | Value |
|---|---|
| **Project Name** | TaskFlow Pro |
| **Description** | A web-based task management application with Scrum workflow support |
| **Start Date** | 2025-01-15 |

## Goals & Scope

### Primary Goals
- Build a Kanban/Scrum task board with drag-and-drop
- User authentication with role-based access
- Real-time collaboration via WebSocket
- Export to CSV/PDF

### Out of Scope
- Mobile app (web-only for v1)
- Third-party integrations (beyond GitHub auth)

## Technical Details

| Field | Value |
|---|---|
| **Primary Language** | TypeScript |
| **Framework** | Next.js 14 / React 18 |
| **Platform/Hosting** | Vercel |
| **Database** | Supabase (PostgreSQL) |
| **Other Services** | GitHub OAuth, WebSockets |

## Success Criteria
- [x] Users can create/organize tasks on a board
- [x] Drag-and-drop between columns
- [x] JWT authentication with role-based access
- [ ] 90% test coverage
- [ ] Sub-100ms board load time
- [ ] Mobile-responsive layout

## Team Capacity

| Field | Value |
|---|---|
| **Number of Developers** | 2 |
| **Sprint Length** | 2 weeks |
| **Velocity (points/sprint)** | 20 |

## GitHub Repository

| Field | Value |
|---|---|
| **Repo URL** | https://github.com/example/taskflow-pro |
| **Default Branch** | main |

## Notes
Project document was provided via doc-mode. No existing repos or Jira projects
found (MCP servers unavailable). Greenfield project — Scrum Master created plan
from scratch.
