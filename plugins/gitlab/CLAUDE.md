# CLAUDE.md — gitlab

Operational shortcut for Claude Code in this directory. **Read
[AGENTS.md](./AGENTS.md) for the full Gibson contract.**

## Local dev loop

| Verb                                   | What it does |
|----------------------------------------|--------------|
| `make build`                           | Compile the binary |
| `make test`                            | Hermetic cassette tests (no daemon/network) |
| `gibson component register --token …`  | First-time enrollment |
| `gibson component run`                 | Run the compiled binary |

## Things not to do

- Do **not** commit `host_key` or anything under `~/.gibson/`.
- Do **not** add `replace` directives or a workspace-root `go.work`; pin the
  SDK by tag.
- Do **not** read the GitLab token from an env var, or log it.
