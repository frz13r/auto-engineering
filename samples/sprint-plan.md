# Sprint Plan — Sprint 1

## Sprint Goal
Build core task board with authentication and drag-and-drop functionality

## Sprint Duration
2 weeks (2025-01-15 to 2025-01-29)
Team Velocity: 20 points
Capacity: 80% (16 points planned)

## Stories in Sprint 1

### Epic: Authentication System (13 points)

| ID | Title | Points | Acceptance Criteria |
|---|---|---|---|
| AUTH-101 | Set up auth schema and user model | 3 | Database schema for users with roles |
| AUTH-102 | Implement JWT login endpoint | 5 | POST /api/auth/login returns JWT |
| AUTH-103 | Add role-based access middleware | 3 | Protected routes reject unauthorized access |
| AUTH-104 | Integrate GitHub OAuth | 5 | OAuth login works with GitHub accounts |

**Total: 16 points** (80% of 20-point velocity)

### Epic: Task Board Core (5 points)

| ID | Title | Points | Acceptance Criteria |
|---|---|---|---|
| BOARD-101 | Create task board API | 5 | CRUD operations for tasks, columns, boards |

## Stories in Future Sprints

### Sprint 2 (planned ~20 points)
- BOARD-102: Drag-and-drop UI (5 pts)
- BOARD-103: Real-time WebSocket updates (8 pts)
- COLLAB-101: User presence indicator (3 pts)
- EXPORT-101: CSV export (3 pts)
- EXPORT-102: PDF export (5 pts)

## Dependencies & Risks

- AUTH-104 depends on AUTH-101, AUTH-102, AUTH-103
- BOARD-101 depends on AUTH-102 (needs authenticated user)
- Risk: GitHub OAuth integration may need enterprise app approval
- Risk: WebSocket support on Vercel edge functions needs verification

## Notes
- No Jira integration (MCP unavailable) — planning done locally
- 2 developers available for parallel work (AUTH-102 + AUTH-103 can run in parallel)
