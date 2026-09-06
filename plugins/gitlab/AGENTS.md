# AGENTS.md — gitlab

This directory is a **Gibson plugin**: a Go service that integrates GitLab into
Gibson missions. It is manifest-driven (`plugin.yaml`) and **Go-first** — the
method contracts come from the Go types in `handler.go`, not from a `.proto`.

If a doc and the SDK source disagree, **the SDK source wins**. Paths below are
bare so you can grep them in `github.com/zeroroot-ai/sdk`.

## What you implement

`handler.go` declares, per method, a typed request/response struct pair and a
core function `f(ctx, *gitlab.Client, Req) (Resp, error)`, plus a thin handler
adapter that resolves the token and builds the client. `main()` wires each
method with `plugin.WithHandler`:

```go
plugin.Serve(
    context.Background(),
    plugin.WithManifest("./plugin.yaml"),
    plugin.WithHandler("GetProject", handleGetProject),
    plugin.WithHandler("ListIssues", handleListIssues),
    plugin.WithHandler("CreateIssue", handleCreateIssue),
)
```

`plugin.WithHandler[Req, Resp]` (`plugin/options.go`) derives the method's
JSON-Schema input/output contract from `Req`/`Resp` at registration. There is no
`.proto`, no `buf`, no generated code.

## The secrets broker — never env vars

The GitLab token is resolved from the SDK secrets broker
(`plugin/secret.go`, `plugin/secrets/`) via `plugin.ResolveSecret(ctx,
"cred:gitlab_token")`. Declare it in `plugin.yaml` under `spec.secrets`. Never
read a token from an env var; never put it in an error, panic, or log line.

## Testing — hermetic, cassette-driven

`handler_test.go` replays committed `testdata/*.json` cassettes of the client-go
HTTP calls through a cassette-backed `*gitlab.Client`. Tests run with a plain
`go test ./...` — no daemon, no network, no token, no build tags (ADR-0065 R7).
Add a method → add a cassette and a sub-test.

## Do not

- Do **not** read the token from an env var — the broker is the only channel.
- Do **not** include the token in errors, panics, or logs.
- Do **not** add `request_proto` / `response_proto` to `plugin.yaml`, or add a
  `.proto` — the contract is derived from Go (ADR-0065 R4).
- Do **not** add `replace` directives or a workspace-root `go.work`; pin the
  SDK by tag.

## Where to look in the SDK (`github.com/zeroroot-ai/sdk`)

| Topic          | Path                             |
|----------------|----------------------------------|
| plugin.Serve   | `plugin/serve.go`                |
| WithHandler    | `plugin/options.go`              |
| ResolveSecret  | `plugin/secret.go`               |
| Manifest schema| `plugin/manifest/manifest.go`    |
