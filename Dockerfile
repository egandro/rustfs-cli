#
# 1. Build the Docker image:
#    docker build -t rustfs-cli .
#
# 2. Run the container:
#    docker run --rm rustfs-cli
#
#    # The application uses internal alias configuration for credentials.
#    # Mount the configuration directory to persist/use aliases:
#    # To avoid permission issues, run with the current user's UID/GID and set HOME to a writable path (e.g., /tmp):
#    docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -v ~/.rustfs-cli:/tmp/.rustfs-cli rustfs-cli
#
# 3. Run with arguments:
#    docker run --rm rustfs-cli --help

FROM rust:1.92-slim-trixie AS builder

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN cargo install --path .

FROM debian:trixie-slim

# This ensures GitHub Actions has permission to write the package.
ARG REPO_URL=""
LABEL org.opencontainers.image.source=${REPO_URL}

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/rustfs-cli /usr/local/bin/rustfs-cli

ENTRYPOINT ["rustfs-cli"]
