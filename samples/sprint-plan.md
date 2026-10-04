# Sprint Plan — Sprint 1

## Sprint Goal
Users can sign in and manage tasks on a basic board.

## Capacity
- Dates: 2025-01-15 → 2025-01-29 (10 working days)
- Velocity: 20 points → capacity_points = floor(0.8 × 20) = **16**
- Planned: **16 points** (AUTH-101 3 + AUTH-102 5 + AUTH-103 3 + BOARD-101 5)
- Developers: 2 → max_concurrent_devs: 2

## Stories in Sprint 1

### Epic: Authentication System (11 points)

| ID | Title | Points | Depends on | Acceptance Criteria |
|---|---|---|---|---|
| AUTH-101 | Set up auth schema and user model | 3 | — | Users table with role field; passwords stored hashed |
| AUTH-102 | Implement JWT login endpoint | 5 | AUTH-101 | `POST /api/auth/login` returns a JWT for valid credentials, 401 otherwise; expired tokens rejected |
| AUTH-103 | Add role-based access middleware | 3 | AUTH-102 | Protected routes return 401 without a token and 403 for the wrong role |

### Epic: Task Board Core (5 points)

| ID | Title | Points | Depends on | Acceptance Criteria |
|---|---|---|---|---|
| BOARD-101 | Create task board API | 5 | AUTH-102 | Authenticated CRUD for boards, columns and tasks |

## Execution Order
1. AUTH-101
2. AUTH-102
3. AUTH-103 and BOARD-101 **in parallel** (both depend only on AUTH-102)

## Future Sprints (backlog)
- AUTH-104: Integrate GitHub OAuth (5 pts) — depends on AUTH-101..103
- BOARD-102: Drag-and-drop UI (5 pts)
- BOARD-103: Real-time WebSocket updates (8 pts)
- EXPORT-101: CSV export (3 pts)

## Risks
- GitHub OAuth (AUTH-104) may need enterprise app approval — start the request now.
- WebSocket support on the hosting platform is unverified (BOARD-103).

## Notes
- Jira unavailable — planned locally with local story IDs.
