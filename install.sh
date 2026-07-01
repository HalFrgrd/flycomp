#!/bin/sh
# Flycomp installer
# Usage: curl -sSfL https://github.com/HalFrgrd/flycomp/releases/latest/download/install.sh | sh

set -eu

expand_path() {
    case "$1" in
        '~/'*) echo "${HOME}/${1#~/}" ;;
        '~')   echo "${HOME}" ;;
        *)     echo "$1" ;;
    esac
}

REPO="HalFrgrd/flycomp"
if [ -n "${FLYCOMP_INSTALL_DIR:-}" ]; then
    INSTALL_DIR="$(expand_path "$FLYCOMP_INSTALL_DIR")"
else
    INSTALL_DIR="${HOME}/.local/bin"
fi


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

say() { printf '\033[1;34m==> \033[0m%s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
err() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || err "Required command not found: $1"
}

download() {
    url="$1"
    dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -sSfL -o "$dest" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest" "$url"
    else
        err "Neither curl nor wget is available. Please install one and retry."
    fi
}

get_latest_version() {
    url="https://github.com/${REPO}/releases/latest"
    if command -v curl >/dev/null 2>&1; then
        tag_url="$(curl -sI "$url" | grep -i '^location:' | head -1)"
    elif command -v wget >/dev/null 2>&1; then
        tag_url="$(wget --max-redirect=0 --server-response -O /dev/null "$url" 2>&1 | grep -i 'location:' | head -1)"
    else
        err "Neither curl nor wget is available. Please install one and retry."
    fi
    version="$(printf '%s' "$tag_url" | sed 's|.*/||' | cut -d' ' -f1 | tr -d '\r\n')"
    [ -n "$version" ] || err "Could not determine latest version from GitHub Release redirect."
    echo "$version"
}

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------

detect_os() {
    os="$(uname -s)"
    case "$os" in
        Linux) echo "linux" ;;
        Darwin) echo "darwin" ;;
        *) err "Unsupported OS: $os" ;;
    esac
}

detect_arch() {
    arch="$(uname -m)"
    case "$arch" in
        x86_64 | amd64) echo "x86_64" ;;
        aarch64 | arm64) echo "aarch64" ;;
        *) err "Unsupported architecture: $arch" ;;
    esac
}

# ---------------------------------------------------------------------------
# Helpers for portability
# ---------------------------------------------------------------------------

verify_sha256() {
    sha256_file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum -c "$sha256_file"
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 -c "$sha256_file"
    else
        err "No checksum tool found (sha256sum or shasum). Cannot verify download."
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    OS="$(detect_os)"
    ARCH="$(detect_arch)"

    if [ "$OS" = "darwin" ]; then
        TARGET="${ARCH}-apple-darwin"
        BIN_NAME="flycomp"
    else
        TARGET="${ARCH}-unknown-linux-musl"
        BIN_NAME="flycomp"
    fi

    say "Detected target: ${TARGET}"

    if [ -n "${FLYCOMP_RELEASE_VERSION:-}" ]; then
        say "Using specified release version: ${FLYCOMP_RELEASE_VERSION}"
        VERSION="${FLYCOMP_RELEASE_VERSION}"
    else
        say "Fetching latest release information..."
        VERSION="$(get_latest_version)"
        say "Latest version: ${VERSION}"
    fi

    ARCHIVE="flycomp-${VERSION}-${TARGET}.tar.gz"
    ARCHIVE_SHA256="${ARCHIVE}.sha256"

    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE}"
    SHA256_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE_SHA256}"

    TMP_DIR="$(mktemp -d)"
    # shellcheck disable=SC2064
    trap "rm -rf '$TMP_DIR'" EXIT

    say "Downloading ${ARCHIVE} from ${DOWNLOAD_URL}..."
    download "$DOWNLOAD_URL" "${TMP_DIR}/${ARCHIVE}"

    if [ -n "$SHA256_URL" ]; then
        say "Downloading checksum from ${SHA256_URL}..."
        download "$SHA256_URL" "${TMP_DIR}/${ARCHIVE_SHA256}"

        say "Verifying checksum..."
        (cd "$TMP_DIR" && verify_sha256 "$ARCHIVE_SHA256") \
            || err "Checksum verification failed for ${ARCHIVE}."
    fi


    mkdir -p "$INSTALL_DIR"

    tar xzf "${TMP_DIR}/${ARCHIVE}" -C "$INSTALL_DIR"
    chmod +x "${INSTALL_DIR}/${BIN_NAME}"

    say "Installed: ${INSTALL_DIR}/${BIN_NAME}"
    say ""
    say "Installation complete!"
}

main "$@"
