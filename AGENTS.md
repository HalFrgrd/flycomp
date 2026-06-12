# AI Agent Developer Guide: `flycomp`

This document provides a simplified overview of [flycomp](.).

`flycomp` parses CLI `--help` outputs and Unix `man` pages to dynamically synthesize shell completion scripts (via `clap_complete`) or output command structures as JSON.

## Key Files
- **[src/lib.rs](src/lib.rs)**: Core data models ([Command](src/lib.rs#L41-L53), [Arg](src/lib.rs#L25-L38)) and dynamic `clap::Command` builder ([to_clap_command](src/lib.rs#L78)).
- **[src/main.rs](src/main.rs)**: CLI entrypoint for testing completion generation.
- **[src/parse_help.rs](src/parse_help.rs)**: Parser for Clap, Argparse, and generic help outputs.
- **[src/parse_man.rs](src/parse_man.rs)**: Groff/man page scrape and parser.
- **[tests/man_pages/](tests/man_pages/)**: Reference manual pages used for testing.

## Useful Commands
```bash
# Build
cargo build

# Test (release build runs much faster)
cargo test --release

# Run / Generate Completions
cargo run -- <command> [options]

# Format the codebase after making changes
cargo fmt
```

## Guidelines
1. **Safety**: The `--help` strategy executes binaries using [std::process::Command](src/lib.rs#L393-L397). Never run untrusted or malicious binaries.
2. **Adding Parsers**: To support new help schemas, update `HelpFormat` in [src/parse_help.rs](src/parse_help.rs) and write matching parser functions.
3. **Tests**: Keep help and man page parser tests within their respective modules. Never hardcode test help texts or man page contents inline; always save them under `tests/help_texts/` or `tests/man_pages/` respectively and load them in the tests.
