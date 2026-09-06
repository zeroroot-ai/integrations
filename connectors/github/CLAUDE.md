# CLAUDE.md — github connector

Operational shortcut for Claude Code in this directory. **Read
[AGENTS.md](./AGENTS.md) for the full connector schema.**

A connector is declarative — one `connector.yaml`, no Go handler. This is the
**Hosted** shape (a vendor MCP image gibson runs). Validate with `go test ./...`.

## Things not to do

- Do **not** add Go handler code — for custom logic you want a **plugin**.
- Do **not** set both `endpoint` and `image` (Hosted uses `image` only).
- Do **not** put a credential in the manifest; `auth` describes how gibson
  obtains the GitHub token at runtime through the broker.
