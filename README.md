# Flycomp

<div align="center">

[![Flycomp CI](https://github.com/HalFrgrd/flycomp/actions/workflows/flycomp-ci.yml/badge.svg)](https://github.com/HalFrgrd/flycomp/actions/workflows/flycomp-ci.yml)
[![License](https://img.shields.io/github/license/HalFrgrd/flycomp)](https://github.com/HalFrgrd/flycomp/blob/master/LICENSE-MIT)
[![Latest Release](https://img.shields.io/github/v/release/HalFrgrd/flycomp)](https://github.com/HalFrgrd/flycomp/releases)

**Generate shell completion scripts and structured command models dynamically from CLI `--help` outputs and Unix man pages.**

[![Demo](https://github.com/HalFrgrd/flycomp/releases/download/assets/demo.gif)](https://github.com/HalFrgrd/evp)

</div>

When you use terminal applications, writing completion scripts manually for every shell (Bash, Zsh, Fish, etc.) is tedious and error-prone. `flycomp` solves this by automatically analyzing:
- [man pages](https://man7.org/linux/man-pages/)
- Help command outputs (`--help` or `help`) for the main command and subcommands

Using these parsed command structures, `flycomp` dynamically generates shell completion scripts via `clap_complete` or outputs them in a structured JSON representation. `flycomp` is currently in use in my [flyline](https://github.com/HalFrgrd/flyline#automatic-completion-synthesis-flycomp) project.


---

# Installation

### Quick install: `install.sh`

> [!TIP]
> No need for `sudo`!
```bash
curl -sSfL https://raw.githubusercontent.com/HalFrgrd/flycomp/master/install.sh | sh
```
This downloads the correct binary from the latest release.
Flyline is built as a statically linked, [musl](https://www.musl-libc.org/) binary so it has zero runtime dependencies!

### Pre-built Releases
Download the pre-compiled binary for your architecture from the [Releases page](https://github.com/HalFrgrd/flycomp/releases).

### Cargo
You can install the `flycomp` binary after cloning the repo using cargo:
```bash
cargo install --path .
```

---

# CLI Usage

Run `flycomp` passing the command you want to synthesize completions for. By default, it will output a **Bash** completion script.

```bash
# Generate Bash completions for grep
flycomp grep

# Generate Zsh completions for git
flycomp git --output zsh

# Output structured JSON of options for the rm command
flycomp rm --output json

# Specify the parsing strategy
flycomp cp --strategy man-page

# Limit deep subcommand exploration depth (defaults to 3)
flycomp docker --recurse-limit 2
```

### Synthesis Strategies
You can control how `flycomp` gathers command metadata via the `--strategy` flag:
- `man-page-or-run-help` (Default): Attempts to parse the command's man page if available, falling back to executing the binary with `--help` if needed.
- `man-page`: Only parse the command's man page files.
- `run-help`: Directly execute the command with `--help` and parse its stdout/stderr.
- `man-page-then-run-help`: Parse the man page first, then run with `--help` to overlay/enrich the parsed structure.

Flycomp tries to use [bwrap](github.com/containers/bubblewrap) when running `--help` for a (sub)command.

---

# Development and Testing

Add test man pages / help texts then run:
```bash
cargo test --release
```
