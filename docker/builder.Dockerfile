# Multi stage docker build using cargo chef.
# https://github.com/LukeMathWalker/cargo-chef

FROM rust:slim AS chef
WORKDIR /app
RUN cargo install cargo-chef --locked

# Stage 2: Planner
FROM chef AS planner
COPY Cargo.toml Cargo.lock build.rs ./
COPY src ./src
RUN cargo chef prepare --recipe-path recipe.json

# Stage 3: Run final Build
FROM chef AS flycomp-builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY Cargo.toml Cargo.lock build.rs ./
COPY .git ./.git
COPY src ./src
RUN cargo build --release

# Build image with output
FROM scratch AS flycomp-built-artifact
COPY --from=flycomp-builder /app/target/release/flycomp /flycomp
