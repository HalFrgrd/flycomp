# Flycomp

<div align="center">

[![Flycomp CI](https://github.com/HalFrgrd/flycomp/actions/workflows/flycomp-ci.yml/badge.svg)](https://github.com/HalFrgrd/flycomp/actions/workflows/flycomp-ci.yml)
[![License](https://img.shields.io/github/license/HalFrgrd/flycomp)](https://github.com/HalFrgrd/flycomp/blob/master/LICENSE-MIT)
[![Latest Release](https://img.shields.io/github/v/release/HalFrgrd/flycomp)](https://github.com/HalFrgrd/flycomp/releases)

**Generate shell completion scripts and structured command models dynamically from CLI `--help` outputs and Unix man pages.**

[![Demo](https://github.com/HalFrgrd/flycomp/releases/download/assets/demo.gif)](https://github.com/HalFrgrd/evp)

</div>

When you use terminal applications, writing completion scripts manually for every shell (Bash, Zsh, Fish, etc.) is tedious and error-prone. `flycomp` solves this by automatically analyzing:
- Help command outputs (`--help` or `-h`) from tools written in `clap` (Rust), `argparse` (Python), EBNF syntax (like `ip`), or generic layout structures.
- Groff-formatted system manual (`man`) pages.

Using these parsed command structures, `flycomp` dynamically compiles them into highly functional, robust shell completion scripts via `clap_complete` or outputs them in a structured JSON representation for use in other line editors (such as [flyline](https://github.com/HalFrgrd/flyline)).

## Who is it for?
1. **Shell Plugin/TUI Developers**: You need a unified, programmatic way to extract command arguments, flags, types, subcommands, and descriptions to provide rich context completion in line-editors.
2. **System Administrators/CLI Users**: You want to quickly bootstrap completion scripts for arbitrary tools that don't ship with native shell completion files.
3. **Rust Developers**: You want to leverage a highly optimized parsing library to parse help text into strongly-typed `Command` structures.

---

# Installation

### Cargo
You can install the `flycomp` binary globally using cargo:
```bash
cargo install --path .
```
Or build from source:
```bash
cargo build --release
```
The built binary will be available at `./target/release/flycomp`.

### Pre-built Releases
Download the pre-compiled binary for your architecture from the [Releases page](https://github.com/HalFrgrd/flycomp/releases).

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
- `man-page`: Only parse the command's groff/man page files.
- `run-help`: Directly execute the command with `--help` and parse its stdout/stderr.
- `man-page-then-run-help`: Parse the man page first, then run with `--help` to overlay/enrich the parsed structure.

---

# How It Works

### 1. Secure Execution Sandboxing
Because executing arbitrary binaries with `--help` can carry risk, `flycomp` automatically executes command-line parsing inside a secure **Bubblewrap** (`bwrap`) sandbox environment if available on the system.
If you need to bypass sandboxing (e.g. inside an already isolated container), use the `--no-sandbox` option:
```bash
flycomp my-custom-binary --no-sandbox
```

### 2. Specialized Help Output Parsers
`flycomp` contains custom parsers tailored for various command-line output layouts:
- **Clap**: Detects structures outputted by Rust's `clap` library, mapping sections like `USAGE`, `Options:`, and `Commands:`.
- **Argparse**: Maps Python's `argparse` layout, grouping positional vs optional parameters.
- **EBNF**: Handles complex argument layout structures (such as `ip` command listings).
- **Generic**: Standard pattern-matching on lines and sections for tools that do not belong to the above categories.

### 3. Groff Page Parser
The `man` page parser cleans raw troff/groff control formatting, strips font escape sequences (like `\fB`, `\fI`, etc.), replaces special macro typography, and parses the standard GNU options layout to construct precise command definitions.

---

# Programmatic Library API (Rust)

Add `flycomp` as a dependency in your `Cargo.toml`:
```toml
[dependencies]
flycomp = { git = "https://github.com/HalFrgrd/flycomp.git" }
```

You can then parse raw help strings or generate shell completions directly in your Rust application:

```rust
use flycomp::{parse_help, OutputFormat};

fn main() {
    let help_text = "
Usage: mytool [OPTIONS]

Options:
  -v, --verbose  Enable verbose logs
  -p <PATH>      Output destination path
";
    
    // Parse raw text into structured Command models
    let cmd = parse_help(help_text).unwrap();
    println!("Parsed command: {:?}", cmd.name);
    
    for arg in cmd.args {
        println!("  Flag: {:?}, Description: {:?}", arg.long, arg.description);
    }
}
```

---

# Development & Testing

### Running Tests
Execute unit and integration tests (which verify the parsing on real-world fixtures for `git`, `curl`, `apt`, `tar`, etc.):
```bash
cargo test --release
```

### Generating Demos
You can generate the demo GIF and SVG recordings using the defined docker bake target:
```bash
docker buildx bake demos
```
