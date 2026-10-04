# MCP Server Setup Guide

The team works with **no MCP servers at all** — it falls back to local planning
and local git. MCP servers add Jira/Confluence planning and context, GitHub PRs,
and Copilot Enterprise knowledge.

## How the team finds MCP tools

The Project Manager decides what is available from the **tools present in its
session**, not from server names. So there are two equally valid setups:

1. **You already have Jira/GitHub MCP servers in your global config**
   (`~/.config/opencode/opencode.json[c]`). Nothing to do — the team uses them.
   Leave the `team-*` servers disabled so you don't get duplicate tools.
2. **You don't.** Enable the bundled `team-*` servers from this repo's
   `opencode.json`, as below.

## Enabling a bundled server

All `team-*` servers ship with `"enabled": false` in the shared `opencode.json`.
To turn one on without editing the shared file, pass an inline config override
when you start OpenCode — it is merged over `opencode.json`:

```bash
OPENCODE_CONFIG_CONTENT='{"mcp":{"team-atlassian":{"enabled":true},"team-github":{"enabled":true}}}' \
  opencode --agent project-manager
```

Use a shell alias if you do this often. Avoid exporting it globally — it applies
to every project you open. If the whole team should have a server on, change
`"enabled"` in `opencode.json` and commit it.

Check the result with `opencode mcp list` (run with the same variable set).

## team-atlassian — Jira + Confluence

Runs [`mcp-atlassian`](https://github.com/sooperset/mcp-atlassian) (pinned) via `uvx`.
Works with Atlassian Cloud and Server/Data Center.

1. Install `uv` (provides `uvx`): https://docs.astral.sh/uv/
2. Create an API token: https://id.atlassian.com/manage-profile/security/api-tokens
3. Export in your shell profile:

```bash
export JIRA_URL=https://your-company.atlassian.net
export JIRA_USERNAME=you@company.com
export JIRA_API_TOKEN=...
export CONFLUENCE_URL=https://your-company.atlassian.net/wiki
export CONFLUENCE_USERNAME=you@company.com
export CONFLUENCE_API_TOKEN=...      # usually the same token as Jira on Cloud
```

## team-github — GitHub / GitHub Enterprise

Runs the official [`github-mcp-server`](https://github.com/github/github-mcp-server)
(pinned image) in Docker.

1. Install and start Docker.
2. Create a Personal Access Token with `repo` and `read:org` scopes.
3. Export:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN=...
export GITHUB_HOST=https://github.your-company.com   # GitHub Enterprise Server only
```

## team-copilot — Microsoft 365 Copilot Enterprise

Remote server at `https://mcp.svc.cloud.microsoft/enterprise`, authenticated with
OAuth (Microsoft Entra ID). Your tenant must have it provisioned.

```bash
opencode mcp auth team-copilot
```

If auth fails with `needs_client_registration`, your tenant doesn't allow
dynamic client registration: ask your admin for an app registration and set
`oauth.clientId` on `team-copilot` (see the OpenCode MCP server docs).

## Verify

```bash
./setup.sh --check  # read-only: validates skills, config and samples (no OpenCode needed)
opencode mcp list   # live MCP connection status
```

`./setup.sh` (without `--check`) also prints which `team-*` and personal MCP
servers are enabled in your resolved config, but it installs or repairs the
pinned skill repos first.

## Permissions note

Agent permissions in `.opencode/agents/*.md` are applied after your global
config, so they override your own global `bash` rules for these agents. Review
them before running the team on a machine with strict local policies.
`opencode.json` also sets `"formatter": false`, so the team's edits don't trigger
formatters; pass `"formatter": true` via `OPENCODE_CONFIG_CONTENT` if your repo
relies on them.

## Troubleshooting

| Issue | Fix |
|---|---|
| "needs authentication" | `opencode mcp auth <server-name>` |
| Duplicate Jira/GitHub tools | You have both a global server and a `team-*` server enabled — disable one |
| 401/403 from Jira | Check the API token and that `JIRA_USERNAME` matches it |
| 401 from GitHub | Check the PAT scopes; for GHE check `GITHUB_HOST` |
| `uvx` / `docker` not found | Install it, or leave that server disabled |
| TLS errors behind a corporate proxy | `team-atlassian` already passes `--native-tls`; make sure your OS trusts the proxy CA |
