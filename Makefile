# Makefile for the Gibson integrations monorepo (ADR-0065).
#
# This repo has no root Go module. Every plugin and every connector is its own
# module, so each target loops over the modules. MODULES defaults to all of
# them and CI overrides it with the modules a pull request changed:
#
#   make test MODULES=plugins/github
#
# These targets are the ONE definition of what CI runs. `.github/workflows/ci.yml`
# calls them, so the commands cannot drift away from the gate.

MODULES ?= $(patsubst %/go.mod,%,$(wildcard plugins/*/go.mod connectors/*/go.mod))

# Each module pins a Go version newer than some installed toolchains. `auto`
# lets the toolchain fetch the pinned version instead of failing the build.
GOTOOLCHAIN ?= auto
export GOTOOLCHAIN

.PHONY: build test check

## build: compile every module.
build:
	@for m in $(MODULES); do \
		echo "==> go build $$m"; \
		( cd "$$m" && go build ./... ) || exit 1; \
	done

## test: run every module's tests. Plugin tests are hermetic cassette tests.
## Connector tests are the manifest schema smoke test.
test:
	@for m in $(MODULES); do \
		echo "==> go test $$m"; \
		( cd "$$m" && go test ./... ) || exit 1; \
	done

## check: static analysis on every module.
check:
	@for m in $(MODULES); do \
		echo "==> go vet $$m"; \
		( cd "$$m" && go vet ./... ) || exit 1; \
	done
