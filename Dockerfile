# syntax=docker/dockerfile:1.5
# avoid-obstacles-game - Linux source image for split-platform CI

FROM swift:6.2 AS builder

WORKDIR /app

# Resolve Swift dependencies to validate package graph on Linux.
COPY Package.* ./
RUN --mount=type=cache,target=/root/.swiftpm,id=swiftpm \
    swift package resolve

COPY . .

FROM swift:6.2-slim

LABEL maintainer="tools-automation"
LABEL description="Avoid Obstacles Game source workspace (Linux tooling image)"

WORKDIR /workspace

RUN groupadd -r gameuser && useradd -r -g gameuser -u 1001 gameuser

COPY --from=builder --chown=root:root --chmod=755 /app /workspace

USER gameuser

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD test -f /workspace/Package.swift || exit 1

CMD ["/bin/sh", "-lc", "echo 'avoid-obstacles-game source container ready (macOS builds app binaries)'; sleep infinity"]
