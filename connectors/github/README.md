# github connector

A Gibson **connector** (ADR-0065 R6): a declarative bridge to GitHub's official
MCP server. The single `connector.yaml` manifest IS the integration — no Go, no
image build of our own.

This is the **Hosted** shape: `connector.yaml` names GitHub's published MCP
image (`ghcr.io/github/github-mcp-server`), which gibson runs on ToolHive behind
a `ConnectorInstance`. It speaks streamable-http (the server binary's `http`
subcommand) and authenticates with a GitHub token (`auth: secret`).

## Validate

```sh
go test ./...   # schema-validation smoke test over connector.yaml
```

The committed smoke test applies the same shape invariants gibson's catalog
loader enforces, so a malformed manifest fails here in CI — long before gibson
loads it. See **[AGENTS.md](./AGENTS.md)** for the manifest schema.
