# Stage 1: build — compiles the plugin binary with CGO disabled.
#
# THE BUILD CONTEXT IS THE REPOSITORY ROOT, not this directory, so every
# COPY path below starts with `plugins/gitlab/`. Build it with:
#
#     docker build -f plugins/gitlab/Dockerfile -t gitlab:<version> .
#
# The root is the context because LICENSE lives there and the image has to
# carry it. Copying LICENSE into each plugin directory instead would make a
# second source of truth that drifts.
FROM golang:1.26.4-alpine@sha256:3ad57304ad93bbec8548a0437ad9e06a455660655d9af011d58b993f6f615648 AS builder

WORKDIR /build
COPY plugins/gitlab/go.mod plugins/gitlab/go.sum* ./
RUN go mod download

COPY plugins/gitlab/ ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/gitlab .

# Stage 2: runtime — minimal image for the pod runtime mode.
FROM gcr.io/distroless/static-debian12:nonroot@sha256:afa5c872c891853ca7fcf1f12c3edb23f7eeef36189728842dd51042ff57f7ab AS runtime

COPY --from=builder /out/gitlab /gitlab
COPY plugins/gitlab/plugin.yaml /etc/gibson/plugin.yaml
# The Elastic License 2.0 requires the notice to travel with a
# distribution, and a published image is one. /licenses is the OCI
# convention. LICENSE sits at the repository root, which is why the
# build context is the root and every COPY above is root-relative.
COPY LICENSE /licenses/LICENSE

EXPOSE 8080

ENTRYPOINT ["/gitlab"]
