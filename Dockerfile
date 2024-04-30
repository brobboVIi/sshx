FROM rust:alpine as backend
WORKDIR /home/rust/src
RUN apk --no-cache add musl-dev openssl-dev protoc
RUN rustup component add rustfmt
COPY . .
ENV RUSTUP_DIST_SERVER=https://mirrors.cernet.edu.cn/rustup
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/home/rust/src/target \
    cargo build --release --bin sshx-server && \
    cp target/release/sshx-server /usr/local/bin

FROM node:lts-alpine as frontend
RUN apk --no-cache add git
WORKDIR /usr/src/app
COPY . .
RUN npm config set registry http://mirrors.cloud.tencent.com/npm/
RUN npm ci
RUN npm run build

FROM alpine:latest
WORKDIR /root
COPY --from=frontend /usr/src/app/build build
COPY --from=backend /usr/local/bin/sshx-server .
CMD ["./sshx-server", "--listen", "::"]
