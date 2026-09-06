# gitlab connector

A Gibson **connector** (ADR-0065 R6): a declarative bridge to GitLab's hosted
MCP server. The single `connector.yaml` manifest IS the integration — no Go, no
image.

This is the **Remote** shape: `connector.yaml` names GitLab's vendor-hosted MCP
endpoint (`https://gitlab.com/api/v4/mcp`), which gibson proxies through the
connector-operator. It speaks streamable-http and negotiates OAuth with the
`mcp` scope (`auth: oauth`).

## Validate

```sh
go test ./...   # schema-validation smoke test over connector.yaml
```

The committed smoke test applies the same shape invariants gibson's catalog
loader enforces, so a malformed manifest fails here in CI — long before gibson
loads it. See **[AGENTS.md](./AGENTS.md)** for the manifest schema.
