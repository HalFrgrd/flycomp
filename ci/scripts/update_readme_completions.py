#!/usr/bin/env python3
import pathlib

def replace_between_markers(lines, start_marker, end_marker, replacement_lines):
    try:
        start = next(i for i, l in enumerate(lines) if l.strip() == start_marker)
        end = next(i for i, l in enumerate(lines) if l.strip() == end_marker)
        return lines[:start] + replacement_lines + lines[end + 1:]
    except StopIteration:
        print(f"Warning: Markers {start_marker} and {end_marker} not found in README.md.")
        return lines

def main():
    readme_path = pathlib.Path("README.md")
    if not readme_path.exists():
        print("Error: README.md not found.")
        return

    lines = readme_path.read_text().splitlines(keepends=True)

    grep_path = pathlib.Path("grep_completion.sh")
    if grep_path.exists():
        grep_text = grep_path.read_text().rstrip("\n")
        grep_replacement = [
            "<!-- GREP_COMPLETION_START -->\n",
            "<details>\n",
            "<summary><b>View `grep` bash completion script output</b></summary>\n\n",
            "```bash\n",
            *[l + "\n" for l in grep_text.splitlines()],
            "```\n",
            "</details>\n",
            "<!-- GREP_COMPLETION_END -->\n"
        ]
        lines = replace_between_markers(lines, "<!-- GREP_COMPLETION_START -->", "<!-- GREP_COMPLETION_END -->", grep_replacement)
    else:
        print("Warning: grep_completion.sh not found.")

    evp_path = pathlib.Path("evp_completion.json")
    if evp_path.exists():
        evp_text = evp_path.read_text().rstrip("\n")
        evp_replacement = [
            "<!-- EVP_COMPLETION_START -->\n",
            "<details>\n",
            "<summary><b>View `evp` options json structure output</b></summary>\n\n",
            "```json\n",
            *[l + "\n" for l in evp_text.splitlines()],
            "```\n",
            "</details>\n",
            "<!-- EVP_COMPLETION_END -->\n"
        ]
        lines = replace_between_markers(lines, "<!-- EVP_COMPLETION_START -->", "<!-- EVP_COMPLETION_END -->", evp_replacement)
    else:
        print("Warning: evp_completion.json not found.")

    readme_path.write_text("".join(lines))
    print("README.md successfully updated with completion contents!")

if __name__ == "__main__":
    main()
