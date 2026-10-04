# Project Context — Blog Posts API

> **Source:** `src/project-doc.md` (Doc Mode), re-verified against the live repo at
> `/home/hades/Documents/play/hermes/autonomous-engineering-team/v1/blog-project`
> on 2026-10-04, after a full workspace reset to baseline commit `90a4cd6`.
>
> ⚠️ **The project doc is wrong on several points.** Corrections are in
> [§12 Corrections](#12-corrections-to-the-project-doc). **Trust this file over
> `src/project-doc.md` where they conflict.**

---

## 1. Project Identity

| Field | Value |
|---|---|
| **Project Name** | Blog Posts API |
| **Description** | Flask 3.0 REST API for blog posts. Post CRUD is complete (pagination, search, sorting). `Category` and `Tag` models exist with full serialization and validation but have **zero API routes**. |
| **Start Date** | 2026-10-04 |
| **Current Milestone** | Sprint 1 — expose Category & Tag management over the API |

## 2. Repository

| Field | Value |
|---|---|
| **Repo URL** | `https://github.com/UNC-GDSC/Blog-Posts-Backend` |
| **Remote name** | `origin` |
| **Default Branch** | `main` |
| **Baseline Commit** | `90a4cd6` — "Merge pull request #1 from UNC-GDSC/claude/reorganize-enhance-repo-011CV6HwTC9voJFFJqFyaovV" |
| **Local Path** | `/home/hades/Documents/play/hermes/autonomous-engineering-team/v1/blog-project` |
| **Git available** | yes — `/usr/bin/git`, valid checkout |
| **Tree state** | clean at reset time |

> **Local repo is authoritative.** GitHub MCP is unavailable → no PRs will be created.
> Developers and Testers work directly in this path and commit to local git.

## 3. MCP Status

```yaml
mcp_status:
  copilot-enterprise: unavailable   # enabled: false in opencode.json + COPILOT_ENTERPRISE_URL unset
  atlassian: unavailable           # enabled: false in opencode.json
  github-enterprise: unavailable    # enabled: false in opencode.json + GITHUB_TOKEN unset
  github-enterprise-proxy: unavailable
  filesystem: available            # enabled: true
```

**Detection evidence:** `opencode.json` sets every server but `filesystem` to
`"enabled": false`. `GITHUB_TOKEN` and `COPILOT_ENTERPRISE_URL` are unset.

### Downstream adaptations (mandatory)

| Agent | Because MCP is unavailable, it MUST |
|---|---|
| **Scrum Master** | Write local `sprint-plan.md` + `sprint-state.json`. Make **no** Jira API calls. Use the local story-ID scheme below. |
| **Developer** | Work in the **local** `blog-project` path. Create **no** PRs. Report `pr: null`. Commit to local git. |
| **Tester** | Run tests **locally** with the project venv. Verify **no** PR/CI checks. |
| **Progress Reporter** | Report local-file evidence only. No Jira links. |

### Story ID scheme (Jira unavailable)

`CAT-<n>` Category · `TAG-<n>` Tag · `POST-<n>` Post↔Tag assignment ·
`ENV-<n>` Environment enablement · `INT-<n>` Integration & regression

## 4. Tech Stack (verified against `requirements.txt`)

| Layer | Version |
|---|---|
| Python | 3.11+ target (`black target-version = ['py311']`); use **3.12** — see §5 |
| Flask | 3.0.0 |
| Flask-SQLAlchemy | 3.1.1 |
| Flask-Migrate | 4.0.5 |
| Flask-CORS | 4.0.0 |
| Flask-Limiter | 3.5.0 |
| SQLAlchemy | 2.0.23 |
| marshmallow | 3.20.1 (declared, **never imported** by current code) |
| flasgger | 0.9.7.1 |
| Faker | 22.0.0 |
| Database | SQLite (dev/test), schema via `db.create_all()` — no migration files needed |
| Tests | pytest 7.4.3, pytest-cov 4.1.0, pytest-flask 1.3.0 |
| Lint/format | flake8 6.1.0 (max-line-length **88**), black 23.12.1 |

## 5. Environment — READ BEFORE WRITING CODE

| Fact | Detail |
|---|---|
| **No virtualenv exists** | Reset removed `blog-project/.venv` (was 97M). Nothing is installed. |
| **`pytest` not importable** | No interpreter has the deps. |
| **`uv` is NOT on `PATH`** | Binary is at **`/home/hades/.hermes/bin/uv`** (uv 0.12.15). Use the absolute path or export it. |
| **`pip` is unusable** | PEP 668 externally-managed environment. Use `uv`. |
| **⚠️ `requirements.txt` is UNSATISFIABLE** | Verified: `black==23.12.1` needs `packaging>=22.0`; `safety==2.3.5` needs `packaging>=21.0,<22.0`. `uv pip install -r requirements.txt` fails with *"No solution found"*. **Never run it** — it fails and can leave a partial venv. |
| **Workaround** | Populate the venv from an explicit package list (omit `safety`, optionally `bandit`). Only **`flake8`** is required by story ACs. |
| **System Pythons** | `/usr/bin/python3.12` (3.12.3) ✅ use this · `/usr/bin/python3` → 3.12.3 · hermes **3.14.7** on PATH as `python3` |
| **⚠️ Python version risk** | The pinned stack predates 3.14. **Build the venv with 3.12**: `/home/hades/.hermes/bin/uv venv --python 3.12 .venv` |
| **Suggested venv sequence** | From `blog-project/`:<br>`/home/hades/.hermes/bin/uv venv --python 3.12 .venv`<br>`/home/hades/.hermes/bin/uv pip install <explicit package list>` |
| **No git identity configured** | `git commit` aborts with `Author identity unknown` (exit 128), local **and** global. Decide deliberately: set a repo-local identity, or use per-command `git -c user.name=... -c user.email=...`. |
| **Port 5000 occupied** | Use 5001/8080 for a manual `run.py`. `app.test_client()` needs no port. |
| **Test command** | `.venv/bin/python -m pytest tests/ -v` from `blog-project/` |
| **Baseline test count** | **20 tests** — 18 in `tests/test_posts.py`, 2 in `tests/test_health.py` |
| **Test DB** | `TestingConfig.SQLALCHEMY_DATABASE_URI = 'sqlite:///test_blog.db'` — **hardcoded**, ignores `DATABASE_URI`. Lands in `blog-project/instance/test_blog.db` (gitignored). The `app` fixture calls `db.drop_all()` on teardown → **two concurrent pytest runs in one tree delete each other's tables.** |

> **`ENV-1` is a hard blocker for every other story.** No venv ⇒ no pytest ⇒ "no
> regressions" cannot be verified. It must land first and prove a green baseline.

## 6. Existing Architecture

```
blog-project/
├── app/
│   ├── __init__.py            # create_app(); register_blueprint at lines 73-74
│   ├── cli.py                 # register_commands()      ← has pre-existing flake8 violations
│   ├── config/config.py       # get_config(); POSTS_PER_PAGE = 10
│   ├── models/
│   │   ├── __init__.py        # db, migrate, imports Post/Tag/Category  ← flake8 E402
│   │   ├── post.py            # Post (category_id, is_published)       ← flake8 E501
│   │   ├── category.py        # Category (hierarchical, parent_id)
│   │   └── tag.py             # Tag + post_tags association table
│   ├── routes/
│   │   ├── __init__.py        # __all__ = ['posts_bp', 'health_bp']   ← MUST BE UPDATED
│   │   ├── posts.py           # reference pattern
│   │   └── health.py
│   └── utils/
│       ├── __init__.py        # handle_error, ValidationError, NotFoundError, paginate
│       ├── errors.py          # custom exceptions + global handlers
│       ├── pagination.py      # paginate() helper
│       ├── middleware.py      #                                ← flake8 E501
│       └── rate_limiter.py    # imports flask_limiter (dep IS installed)
└── tests/
    ├── conftest.py            # app, client, runner, sample_post, multiple_posts
    ├── test_health.py         # 2 tests
    └── test_posts.py          # 18 tests                       ← flake8 F401
```

### Mandatory patterns (from `app/routes/posts.py`)

```python
from flask import Blueprint, request, jsonify
from app.models import db, Post
from app.utils import ValidationError, NotFoundError, paginate

posts_bp = Blueprint('posts', __name__, url_prefix='/api/v1/posts')
```

Handler shape, in order:

1. Read input — `request.get_json()` / `request.args`
2. Validate — `Model.validate_*_data(data)` → `(is_valid, error_message)`; raise `ValidationError(error_message)`
3. Fetch — `Model.query.get(id)`; raise `NotFoundError(f"... with ID {id} not found")` if missing
4. Mutate + `db.session.add()` / `db.session.commit()`
5. Return `jsonify(model.to_dict()), <status>` — `200` reads/updates, `201` creates

Status codes in use: `200` GET/PUT/DELETE, `201` POST, `400` via `ValidationError`,
`404` via `NotFoundError`. Error bodies: `{'error': ..., 'message': ...}`.

### Blueprint registration is a TWO-FILE change

- `app/routes/__init__.py` — add the import **and** extend `__all__`
- `app/__init__.py` — add to the `from app.routes import ...` line **and** add `app.register_blueprint(...)` beside lines 73–74

Verified current state:
```
app/routes/__init__.py:5   __all__ = ['posts_bp', 'health_bp']
app/__init__.py:73-74      app.register_blueprint(posts_bp) / (health_bp)
```
A blueprint exported but never registered is **silently dead — 404 on every route.**

### `paginate()` helper gotchas (`app/utils/pagination.py`)

- Signature: `paginate(query, endpoint='posts.get_posts')` — **each new list endpoint must pass its own endpoint** or `url_for` builds wrong `next_page`/`prev_page` links.
- Envelope: `{'items': [...], 'meta': {page, per_page, total_items, total_pages, has_next, has_prev, next_page?, prev_page?}}`
- `per_page` is **hardcoded `10`** in the helper; it does **not** read `app.config['POSTS_PER_PAGE']`. Cap is 100. Do not "fix" this — out of scope.
- `url_for(..., _external=True)` → absolute URLs. Fine in tests.

### Model capabilities already present — reuse, do not rewrite

**`Category`** (`app/models/category.py`)
- `to_dict(include_children=False)` → `id, name, slug, description, parent_id, created_at, post_count`
- `create_slug(name)` static → lowercase, strips punctuation, spaces→`-`
- `validate_category_data(data)` static → `(bool, msg)`; name required, **≤100 chars**, non-whitespace
- `parent_id` self-FK. `children` and `posts` are **`lazy='dynamic'`** → iterate `for child in cat.children:` or call `.all()` / `.count()`. **Never JSON-serialize a relationship directly.**
- backref `Post.category`

**`Tag`** (`app/models/tag.py`)
- `to_dict()` → `id, name, slug, description, created_at, post_count`
- `create_slug(name)` static — same algorithm
- `validate_tag_data(data)` static; name required, **≤50 chars**, non-whitespace
- `post_tags` association table exists; `Tag.posts` and backref `Post.tags` are both **`lazy='dynamic'`** → use `.all()` / `.count()`

⚠️ **Slug/name uniqueness is DB-enforced** (`unique=True, index=True` on both `name`
and `slug`) but **no model-level or route-level duplicate check exists**. A duplicate
raises an unhandled `sqlalchemy.exc.IntegrityError` → surfaces as a generic **500**
via the catch-all handler, not a clean 400/409. **Every create/update route needs an
explicit pre-check** raising `ValidationError` (400). Check the **derived slug**, not
just the name — `"Tech!"` and `"Tech"` are different names but the same slug.

⚠️ **`post_count` requires an app context** (`self.posts.count()`). Assert it through
the `client` fixture, never outside a request/app context.

⚠️ **`Post.to_dict()` already emits `category_id`** — verified at `app/models/post.py`.
It is **not** a story.

## 7. Scope

### In scope
- `/api/v1/categories` — GET list (paginated), GET one, POST, PUT, DELETE
- Hierarchical categories via `parent_id` — set on create/update; list children
- `/api/v1/tags` — GET list, GET one, POST, PUT, DELETE
- Slug auto-generation from `name` on create; re-slug on name change
- `PATCH /api/v1/posts/<id>/tags` — `{"action": "add"|"remove", "tag_ids": [1,2]}`
- Tests for all of the above (TDD: test first, then implement)
- Register new blueprints in **both** `app/routes/__init__.py` and `app/__init__.py`
- Environment enablement (venv + deps) so the suite is runnable

### Explicitly OUT of scope
- Authentication / authorization
- Rate limiting (infrastructure exists; do not extend it)
- Frontend, or Swagger/Flasgger doc updates
- Migration scripts (schema comes from `db.create_all()`)
- Refactoring `paginate()` to read `POSTS_PER_PAGE`
- `marshmallow` schemas (declared but unused)
- Updating `Post.to_dict()` to include `category_id` (already done)

## 8. Success Criteria (from project doc, minus the already-satisfied item)

- [ ] `GET /api/v1/categories` returns a paginated list
- [ ] `GET /api/v1/categories/<id>` returns a single category with `post_count`
- [ ] `POST /api/v1/categories` creates a category with auto-generated slug
- [ ] `PUT /api/v1/categories/<id>` updates a category
- [ ] `DELETE /api/v1/categories/<id>` deletes a category
- [ ] `GET /api/v1/tags` returns a list of tags
- [ ] `GET /api/v1/tags/<id>` returns a single tag with `post_count`
- [ ] `POST /api/v1/tags` creates a tag with auto-generated slug
- [ ] `PUT /api/v1/tags/<id>` updates a tag
- [ ] `DELETE /api/v1/tags/<id>` deletes a tag
- [ ] `PATCH /api/v1/posts/<id>/tags` adds/removes tags from a post
- [ ] All of the above return correct HTTP status codes and JSON
- [ ] All new tests pass: `pytest tests/ -v`
- [ ] No existing tests break

## 9. Team Capacity

| Field | Value |
|---|---|
| Number of Developers | 2 |
| Sprint Length | 2 weeks |
| Velocity | 20 points/sprint |
| Board Capacity | 80% |
| **Effective capacity for Sprint 1** | **16 points** |
| **Parallelism ceiling** | **`max_concurrent_devs = 2`** |
| Tester | 1 (verification is therefore serial) |

**Serialization hazard:** both developer workstreams will touch
`app/routes/__init__.py` and `app/__init__.py`. The plan **must** make ownership
explicit — `context.md` sanctions either **a single owner** who registers both
blueprints in one commit, **or** a strictly serialized order where each dev writes
once. Both blueprints must be registered for their stories to be verifiable at all.

**Shared-tree hazard:** with `max_concurrent_devs = 2` in **one working tree** and one
hardcoded SQLite file with `db.drop_all()` teardown, and **one shared git index**,
concurrent agents will interfere. Any parallel dispatch needs an explicit mutual
exclusion mechanism around `pytest` runs and around `git add`/`commit` — plus a
prohibition on `git add -A`, `git commit -a`, bare `git commit`, `git stash`, and
`git checkout --`.

## 10. Suggested Feature Breakdown (input to Scrum Master — refine, do not copy)

| ID | Title | Notes |
|---|---|---|
| `ENV-1` | Environment enablement + green baseline | Explicit package list (NOT `-r requirements.txt`); **blocks everything** |
| `CAT-1` | Category list + detail endpoints | Includes blueprint registration; `paginate(endpoint='categories.get_categories')` |
| `CAT-2` | Category create/update/delete + slug + **duplicate pre-check** | Needs the explicit pre-check |
| `TAG-1` | Tag list + detail endpoints | |
| `TAG-2` | Tag create/update/delete + slug + **duplicate pre-check** | Note the **50**-char limit |
| `POST-1` | `PATCH /api/v1/posts/<id>/tags` | Edits `app/routes/posts.py`; no new blueprint |
| `INT-1` | Integration + regression sweep | Full suite green, flake8 clean |

## 11. Conventions

- Line length **88** (flake8 and black agree)
- Single quotes in `app/`; black configured but not enforced in CI
- `f"Category with ID {id} not found"` style for `NotFoundError`
- Type hints on handler args; docstrings with `Args:` / `Returns:` / `Raises:`
- Tests in `tests/test_<domain>.py`, mirroring `tests/test_posts.py` (`json.loads(response.data)` + plain asserts, grouped in `Test<Endpoint>` classes)

## 12. Corrections to the Project Doc

| # | Project doc says | Reality (verified) | Action |
|---|---|---|---|
| 1 | `flask_limiter` imported but missing from `requirements.txt` | `Flask-Limiter==3.5.0` **is** present under a `# Rate limiting` heading | Drop that work — but note `requirements.txt` as a whole is unsatisfiable (§5) |
| 2 | "Update `Post.to_dict()` to include `category_id`" | Already includes `category_id`, `category`, `tags` | Remove from scope. Not a story. |
| 3 | Only `app/routes/__init__.py` needs updating | Registration needs **both** `app/routes/__init__.py` (import + `__all__`) **and** `app/__init__.py` (`register_blueprint`) | Plan must cover both or every new route 404s |
| 4 | Implied: environment ready to run tests | **No venv, zero deps, `pytest` unrunnable**, and `requirements.txt` cannot be installed as-is | Blocking `ENV-1` story required |
| 5 | "venv created with `uv`" | True, but `uv` is **not on PATH** and the **Python version matters** — PATH `python3` is 3.14.7, pins predate it | Use absolute `/home/hades/.hermes/bin/uv` and pin **3.12** |
| 6 | "Project uses `POSTS_PER_PAGE = 10`" | `paginate()` **hardcodes `per_page=10`** and never reads the config | Behaviour matches by coincidence. Don't refactor — out of scope. |
| 7 | (not mentioned) | **No git identity configured** — `git commit` fails with exit 128 | Decide before the first commit |
| 8 | (not mentioned) | **Pre-existing flake8 violations** in `app/cli.py`, `app/models/__init__.py`, `app/models/post.py`, `app/utils/middleware.py`, `tests/test_posts.py` | Story ACs must be **file-scoped**. "flake8 clean" never means repo-wide. |

## 13. Handoff File Map

| File | Produced by | Read by |
|---|---|---|
| `src/project-doc.md` | human | PM |
| `context.md` | **PM** | Scrum Master, Developer, Tester, Reporter |
| `sprint-plan.md` | Scrum Master | Developer, Tester |
| `sprint-state.json` | Scrum Master | PM, Reporter |
| `dev-outputs/<STORY>.json` | Developer | Tester, PM |
| `test-outputs/<STORY>.json` | Tester | PM |
| `progress-reports/<date>.md` | Reporter | PM, human |