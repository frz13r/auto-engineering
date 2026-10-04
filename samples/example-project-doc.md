# Blog Posts API — Add Category & Tag Management

## Project Overview

| Field | Value |
|---|---|
| **Project Name** | Blog Posts API |
| **Description** | A Flask 3.0 REST API for managing blog posts. Currently has full CRUD for posts (with pagination, search, sorting) but Category and Tag models exist with NO API routes — they are never exposed to clients. |
| **Project Manager** | Autonomous Engineering Team (PM agent) |
| **Start Date** | 2026-10-04 |

## Goals & Scope

### Primary Goals
- Add REST API CRUD endpoints for **Categories** (`/api/v1/categories`)
  - GET (list with pagination), GET (single), POST, PUT, DELETE
  - Slug auto-generation from name (model already has `create_slug` method)
  - Hierarchical categories (parent_id) — create, list children
- Add REST API CRUD endpoints for **Tags** (`/api/v1/tags`)
  - GET (list), GET (single), POST, PUT, DELETE
  - Slug auto-generation from name (model already has `create_slug` method)
- Add **Tag assignment to Posts** — PATCH endpoint to add/remove tags from a post
  - `PATCH /api/v1/posts/<id>/tags` with `{"action": "add", "tag_ids": [1, 2]}` or `{"action": "remove", "tag_ids": [3]}`
- Write tests for all new endpoints (TDD — tests first, then implementation)
- Update `Post.to_dict()` to include `category_id` in the serialized output (it already serializes category object when set)

### Out of Scope
- User authentication / authorization
- Rate limiting (infrastructure already exists but is not the focus)
- Frontend or Swagger documentation updates
- Migration scripts (database is created via `db.create_all()`)

## Technical Details

| Field | Value |
|---|---|
| **Primary Language** | Python 3.11+ |
| **Framework** | Flask 3.0.0 |
| **Platform/Hosting** | Local development (Flask dev server) |
| **Database** | SQLite (development/test) |
| **ORM** | SQLAlchemy 2.0.23 |
| **Migrations** | Flask-Migrate 4.0.5 (but app uses `db.create_all()`) |
| **Testing** | pytest 7.4.3, pytest-flask |

### Tech Stack
- Flask 3.0.0, Flask-SQLAlchemy 3.1.1, Flask-CORS, Flasgger (Swagger docs)
- The app has a `rate_limiter.py` that imports `flask_limiter` — **this package is missing from requirements.txt**. The developer will need to add it or work around it.
- Patterns to follow: `app/routes/posts.py` (Blueprint + validation + error handling)
- Models already exist in `app/models/`: `Post`, `Category`, `Tag` (with `to_dict`, `validate_*_data`, `create_slug` static methods)
- The `app/routes/__init__.py` needs updating to register new blueprints

### Constraints
- Follow the existing code patterns exactly (Blueprint, ValidationError, NotFoundError, paginate)
- Tests must pass: `pytest tests/ -v`
- The project uses `POSTS_PER_PAGE = 10` for pagination default
- Create the virtualenv with `uv` (`uv venv && uv pip install -r requirements.txt`)

## Success Criteria
- [ ] `GET /api/v1/categories` returns paginated list of categories
- [ ] `GET /api/v1/categories/<id>` returns a single category with post_count
- [ ] `POST /api/v1/categories` creates a category with auto-generated slug
- [ ] `PUT /api/v1/categories/<id>` updates a category
- [ ] `DELETE /api/v1/categories/<id>` deletes a category
- [ ] `GET /api/v1/tags` returns list of tags
- [ ] `GET /api/v1/tags/<id>` returns a single tag with post_count
- [ ] `POST /api/v1/tags` creates a tag with auto-generated slug
- [ ] `PUT /api/v1/tags/<id>` updates a tag
- [ ] `DELETE /api/v1/tags/<id>` deletes a tag
- [ ] `PATCH /api/v1/posts/<id>/tags` adds/removes tags from a post
- [ ] All acceptance criteria above return correct HTTP status codes and JSON
- [ ] All new tests pass: `pytest tests/ -v`
- [ ] No existing tests break

## Team Capacity

| Field | Value |
|---|---|
| **Number of Developers** | 2 |
| **Sprint Length** | 2 weeks |
| **Velocity (points/sprint)** | 20 |
| **Board Capacity (%)** | 80% |

### Team Members
| Name | Role | Jira Handle |
|---|---|---|
| (Framework Default) | Developer 1 | N/A |
| (Framework Default) | Developer 2 | N/A |
| (Framework Default) | Tester | N/A |

## GitHub Repository

| Field | Value |
|---|---|
| **Repo URL** | https://github.com/UNC-GDSC/Blog-Posts-Backend |
| **Default Branch** | main |
| **Test Command** | `pytest tests/ -v` |
| **Local Path** | (clone of the repo above, e.g. `./workspace/blog-project`) |

## MCP Context Gathering Results

### Copilot Enterprise Findings
- N/A (MCP unavailable)

### Confluence Documentation
- N/A (MCP unavailable)

### GitHub Repo Patterns
- Blueprint-based routing pattern (see `app/routes/posts.py`)
- Error handling via custom `ValidationError` and `NotFoundError` exceptions
- Pagination via `paginate()` utility that wraps SQLAlchemy queries
- Model serialization via `to_dict()` methods
- Slug generation via `Model.create_slug(name)` static method
- Input validation via `Model.validate_*_data(data)` static methods

### Existing Jira Projects
- N/A (MCP unavailable)

## Notes

### Key Observations
1. The `Category` and `Tag` models have full `to_dict()`, `create_slug()`, and `validate_*_data()` methods but ZERO API routes
2. The `Post.to_dict()` already serializes `category` and `tags` — but there's no way to set them via API
3. `app/routes/__init__.py` registers only `posts_bp` and `health_bp` — new blueprints need registering
4. `flask_limiter` is imported in `app/utils/rate_limiter.py` but is NOT in `requirements.txt` — this causes an import error. Add `Flask-Limiter` to `requirements.txt` as part of the first story.

### Feature Breakdown (for Scrum Master)
- **Story 1**: Category CRUD API — endpoints, models already exist, need routes + tests
- **Story 2**: Tag CRUD API — endpoints, models already exist, need routes + tests
- **Story 3**: Tag assignment to Posts — PATCH endpoint to add/remove tags
- **Story 4**: Integration testing — verify everything works together, no regressions
