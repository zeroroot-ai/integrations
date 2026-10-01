# integrations — CLAUDE.md

> **Workflow rules:** see [`zeroroot-ai/.github` → `AGENTS.md`](https://github.com/zeroroot-ai/.github/blob/main/AGENTS.md) — canonical for branching / commits / PRs / releases / merging. Conventional Commits MANDATORY. Never push to main. Never force-push.

This file is the per-repo addendum. Workspace-wide concerns live in the workspace `CLAUDE.md` and in [`AGENTS.md`](https://github.com/zeroroot-ai/.github/blob/main/AGENTS.md).

## TL;DR

First-party connectors and plugins for Gibson, built on the public Gibson SDK (ADR-0065). Every integration is one self-contained directory with its own Go module. Start with `make build test check`, which loops over every module and is the same command CI runs.

## Architecture

There is **no root Go module**. Each integration under `plugins/<vendor>/` or `connectors/<vendor>/` carries its own `go.mod`, so it is testable and releasable on its own, and a fork inherits the layout and the CI unchanged.

Two lanes, chosen by what the integration has to do:

| Lane | Directory | What it is | You write |
|---|---|---|---|
| **Plugin** | `plugins/<vendor>/` | A Go service running custom logic against a vendor API | `handler.go` — typed Go structs plus `plugin.WithHandler`. No `.proto`. |
| **Connector** | `connectors/<vendor>/` | A declarative bridge to a vendor's MCP server | `connector.yaml` — one manifest, no code. |

Each integration directory carries its own `CLAUDE.md` and `AGENTS.md`. Read the one next to the code you are changing; this file covers only the repo as a whole.

**License: Elastic License 2.0.** Source-available, not open source. GitHub's detector does not recognize ELv2 and reports `NOASSERTION`, so the sidebar says nothing — `LICENSE` is the statement.

## Commands

The Makefile targets are the **one** definition of what CI runs. `.github/workflows/ci.yml` calls them, so the commands cannot drift away from the gate.

```bash
make build                      # go build every module
make test                       # go test every module
make check                      # go vet every module
make test MODULES=plugins/github   # one module only
```

`MODULES` defaults to every `*/go.mod` under `plugins/` and `connectors/`. CI overrides it with the modules the pull request changed, so a PR touching one integration does not build all of them.

## Gotchas

- **`MODULES` is how CI scopes a run.** If you add an integration, it is picked up by the `wildcard` glob automatically — but only if it has a `go.mod`. A directory without one is silently skipped by every target.
- **`GOTOOLCHAIN=auto` is deliberate.** Each module pins a Go version newer than some installed toolchains. The Makefile exports `auto` so the toolchain fetches the pinned version instead of failing the build. Do not pin it to `local`.
- **A connector has no image to pin, a plugin does.** `shape: Remote` connectors reach a vendor's own MCP server. A `shape: Hosted` entry runs an image in the tenant data plane and must be pinned by digest, never a floating tag.
- **Plugin tests are hermetic cassette tests.** They must not reach the network. Connector tests are the manifest schema smoke test.

## Links

- Org-level workflow: [`AGENTS.md`](https://github.com/zeroroot-ai/.github/blob/main/AGENTS.md)
- The SDK these build on: [`zeroroot-ai/sdk`](https://github.com/zeroroot-ai/sdk)
- Per-integration guidance: `plugins/<vendor>/CLAUDE.md`, `connectors/<vendor>/CLAUDE.md`
- Workspace map: workspace `CLAUDE.md`
