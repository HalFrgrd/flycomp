# Base image for demo generation
FROM ubuntu:24.04 AS demo-base

# Create a non-root user for demos
RUN useradd -m -s /bin/bash john

WORKDIR /app

# Give john ownership of the app directory
RUN chown -R john:john /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    faketime \
    fonts-noto-color-emoji \
    fonts-noto-mono \
    fontconfig \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -f -v

USER john

# Ensure build-time RUN steps can resolve demo helper binaries.
ENV PATH="/home/john/bin:${PATH}"

ENV EVP_VERSION=v0.13.0
ENV EVP_INSTALL_DIR=/home/john/bin
RUN sh -c '/usr/bin/curl -sSfL https://raw.githubusercontent.com/HalFrgrd/evp/master/install.sh | sh'

RUN touch /home/john/.bashrc && \
    printf '%s\n' \
    'source /usr/share/bash-completion/bash_completion' \
    'source /etc/bash_completion' \
    'export PATH="/home/john/bin/:$PATH"' \
    >> /home/john/.bashrc

# Copy mock bwrap to path and make it executable
RUN mkdir -p /home/john/bin
COPY docker/bwrap /home/john/bin/bwrap
USER root
RUN chmod +x /home/john/bin/bwrap
USER john
