# Gibson integrations

First-party connectors and plugins for [Gibson](https://github.com/zeroroot-ai),
built on the public [Gibson SDK](https://github.com/zeroroot-ai/sdk) (ADR-0065).

Every integration is a single directory: self-contained, individually testable,
and authorable by an AI coding agent in about ten minutes. This repo is the
worked reference for both integration lanes — a fork inherits the layout and the
CI unchanged.

## The two lanes

Gibson integrates an external system in one of two shapes. Pick by what the
integration needs to do:

| Lane | Directory | What it is | You write |
|------|-----------|------------|-----------|
| **Plugin** | `plugins/<vendor>/` | A Go service that runs custom logic against a vendor API. Go-first (ADR-0065 R4). | `handler.go` — typed Go request/response structs + `plugin.WithHandler`. No `.proto`. |
| **Connector** | `connectors/<vendor>/` | A declarative bridge to a vendor's MCP server. No code (ADR-0065 R6). | `connector.yaml` — one manifest. |

**Rule of thumb:** if the vendor already speaks MCP, write a **connector** (a
YAML file). If you need to run your own code — call a REST API, transform a
result, enrich the graph — write a **plugin**.

## Add a plugin

```sh
gibson component init <vendor> --kind plugin --dir plugins/
cd plugins/<vendor>
go test ./...        # runs the hermetic cassette test
```

Each plugin is its **own Go module**, pinning the SDK by tag. Author the typed
`EchoRequest`/`EchoResponse` structs and the handler in `handler.go`; the SDK
derives each method's JSON-Schema contract from the Go types at registration.
Record a request/response cassette under `testdata/` and assert it in
`handler_test.go` — the test is fully hermetic (no daemon, no network). A
`Dockerfile` builds the pod-runtime image; `helm/values.yaml` is the umbrella
wiring stub. See `plugins/example/` and its `AGENTS.md`.

## Add a connector

```sh
gibson component init <vendor> --kind connector --dir connectors/
cd connectors/<vendor>
go test ./...        # schema-validation smoke test
```

A connector is one `connector.yaml` — no Go handler code. Set the vendor's
`shape` (`Remote` for a vendor-hosted MCP server Gibson proxies, `Hosted` for a
container image Gibson runs), the `endpoint`/`image`, `transport`, `auth`, and
`egressAllow`. The committed smoke test applies the same shape invariants
Gibson's catalog loader enforces, so a malformed manifest fails here — in this
repo's CI — long before Gibson loads it. See `connectors/osv/`.

## CI

`.github/workflows/ci.yml` is path-filtered and per-module: a PR touching
`plugins/<x>/` or `connectors/<x>/` runs only that module, and builds a
container image for each changed plugin. A push to `main` runs every module. No
secrets are needed, because the Gibson SDK is public.

CI calls the root `Makefile`, so one command set serves the gate and your
workstation:

| Target | What it runs |
|--------|--------------|
| `make build` | `go build ./...` in every module |
| `make test` | `go test ./...` in every module |
| `make check` | `go vet ./...` in every module |

Pass `MODULES=` to narrow the loop, the way CI narrows it to the modules a pull
request changed:

```sh
make test MODULES=plugins/github
```

## Licensing

The contents of this repo are licensed under the **Elastic License 2.0** (see
`LICENSE`): read, download, run and modify, but not offer to third parties as a
hosted or managed service. The Gibson SDK they build on stays Apache-2.0, so
what you write against the SDK is unaffected by this repo's terms.

## License and history

Elastic License 2.0. See [LICENSE](LICENSE). Zero Root AI is the licensor.

Issue and pull request numbers cited in comments and documents dated before 2026-09-05 refer to the tracker before the history reset, archived offline. They do not resolve on GitHub.
