# CLAUDE.md — gitlab connector

Operational shortcut for Claude Code in this directory. **Read
[AGENTS.md](./AGENTS.md) for the full connector schema.**

A connector is declarative — one `connector.yaml`, no Go handler. This is the
**Remote** shape (a vendor-hosted MCP endpoint gibson proxies). Validate with
`go test ./...`.

## Things not to do

- Do **not** add Go handler code — for custom logic you want a **plugin**.
- Do **not** set both `endpoint` and `image` (Remote uses `endpoint` only).
- Do **not** put a credential in the manifest; `auth`/`oauthScope` describe how
  gibson obtains one at runtime through the broker.
