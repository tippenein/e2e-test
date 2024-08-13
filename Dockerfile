FROM --platform=$BUILDPLATFORM rust:1.68 as builder

ARG CLARINET_VERSION=v2.8.0
WORKDIR /usr/src/clarinet

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# building from source because I wasn't able to get the platform working from binary
RUN git clone https://github.com/hirosystems/clarinet.git . && \
    git checkout ${CLARINET_VERSION} && \
    cargo build --release

# Final stage
FROM --platform=$BUILDPLATFORM ubuntu:latest

RUN apt-get update && apt-get install -y \
    ca-certificates \
    docker.io \
    sudo \
    net-tools \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*
RUN usermod -aG docker root



COPY --from=builder /usr/src/clarinet/target/release/clarinet /usr/local/bin/clarinet

WORKDIR /app
VOLUME /var/run/docker.sock


# Copy Clarinet config files
COPY Clarinet.toml .
COPY settings/Devnet.toml ./settings/
COPY start.sh .

RUN chmod +x start.sh

CMD ["/app/start.sh"]
