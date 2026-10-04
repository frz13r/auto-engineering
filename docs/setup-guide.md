# MCP Server Setup Guide

This guide walks through configuring the three MCP servers needed for the autonomous engineering team.

## Prerequisites

- OpenCode CLI installed (`npm install -g opencode-ai`)
- Node.js 18+
- Network access to your enterprise services

## 1. MS Copilot Enterprise MCP

### Endpoint
```
https://mcp.svc.cloud.microsoft/enterprise
```

### Setup
1. Ensure you have Microsoft Entra ID access with appropriate Graph API permissions
2. In OpenCode, run:
```bash
opencode mcp add copilot-enterprise --url https://mcp.svc.cloud.microsoft/enterprise
```
3. When prompted, complete the OAuth login flow in your browser
4. Verify with `opencode mcp list`

### Required Permissions
- `MCP.*` API permissions in your Entra app registration
- Admin consent granted

## 2. Atlassian MCP (Jira + Confluence)

### Option A: Official Atlassian Remote MCP (Cloud)
1. Install the mcp-remote proxy:
```bash
npm install -g mcp-remote
```
2. In OpenCode, run:
```bash
opencode mcp add atlassian --url https://mcp.atlassian.com/v1/sse
```
3. Complete the Atlassian OAuth flow when prompted
4. Verify with `opencode mcp list`

### Option B: Local MCP Server (Cloud and Server/Data Center)
For on-premises Atlassian or more control:
1. Install the community mcp-atlassian server:
```bash
npx -y mcp-atlassian
```
2. Configure environment variables:
```bash
JIRA_URL=https://your-company.atlassian.net
JIRA_USERNAME=you@company.com
JIRA_API_TOKEN=your_api_token
CONFLUENCE_URL=https://your-company.atlassian.net/wiki
CONFLUENCE_USERNAME=you@company.com
CONFLUENCE_API_TOKEN=your_api_token
```
3. Add to opencode.json under `mcp.servers.atlassian`

## 3. GitHub MCP Server

### Setup
1. Create a GitHub Personal Access Token (PAT) with:
   - `repo` (full control of private repos)
   - `read:org` (read org data)
   - `workflow` (update GitHub workflow)
2. Store it securely:
```bash
opencode providers login github
# Or set env var:
export GITHUB_TOKEN=ghp_your_token_here
```
3. Add the server:
```bash
opencode mcp add github-enterprise -- npx -y @modelcontextprotocol/server-github
```

## Verification

After setup, verify all servers:
```bash
opencode mcp list
```

Expected output:
```
✓ copilot-enterprise connected
✓ atlassian connected
✓ github-enterprise connected
✓ filesystem connected
```

## Troubleshooting

| Issue | Solution |
|---|---|
| "needs authentication" | Run `opencode mcp auth <server-name>` |
| 403 on Jira | Check API token permissions and Jira site access |
| 403 on GitHub | Verify PAT has correct scopes |
| MCP server crashes | Check Node version >= 18, restart OpenCode |
| Copilot Enterprise not available | Must be provisioned by your IT admin via Microsoft |
