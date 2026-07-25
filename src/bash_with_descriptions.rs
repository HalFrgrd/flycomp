use crate::Command;

fn find_desc_in_cmd<'a>(token: &'a str, cmd: &'a Command) -> Option<&'a str> {
    for arg in &cmd.args {
        if let Some(short) = &arg.short {
            let s = short.trim_start_matches('-');
            if token == short || token == format!("-{}", s) {
                if let Some(d) = &arg.description {
                    return Some(d.as_str());
                }
            }
        }
        if let Some(long) = &arg.long {
            let l = long.trim_start_matches('-');
            if token == long || token == format!("--{}", l) {
                if let Some(d) = &arg.description {
                    return Some(d.as_str());
                }
            }
        }
        if let Some(vn) = &arg.value_name {
            let clean_vn = vn.trim_matches(|c| c == '<' || c == '>');
            if token == vn
                || token == clean_vn
                || token == format!("[{}]", clean_vn)
                || token == format!("<{}>", clean_vn)
            {
                if let Some(d) = &arg.description {
                    return Some(d.as_str());
                }
            }
        }
    }

    for sub in &cmd.subcommands {
        if let Some(name) = &sub.name {
            if token == name {
                if let Some(d) = &sub.description {
                    return Some(d.as_str());
                }
            }
        }
        for alias in &sub.aliases {
            if token == alias {
                if let Some(d) = &sub.description {
                    return Some(d.as_str());
                }
            }
        }
    }

    None
}

fn find_command_by_path<'a>(root: &'a Command, path: &[String]) -> Option<&'a Command> {
    if path.is_empty() {
        return Some(root);
    }
    let mut current = root;
    for segment in path.iter().skip(1) {
        if let Some(sub) = current.subcommands.iter().find(|s| {
            s.name.as_deref() == Some(segment.as_str())
                || s.aliases.iter().any(|a| a == segment.as_str())
        }) {
            current = sub;
        } else {
            return None;
        }
    }
    Some(current)
}

fn find_description_for_token<'a>(
    token: &'a str,
    cmd_path: &[String],
    root_cmd: &'a Command,
) -> Option<&'a str> {
    let target_cmd = find_command_by_path(root_cmd, cmd_path).unwrap_or(root_cmd);
    if let Some(desc) = find_desc_in_cmd(token, target_cmd) {
        return Some(desc);
    }
    if (target_cmd as *const Command) != (root_cmd as *const Command) {
        if let Some(desc) = find_desc_in_cmd(token, root_cmd) {
            return Some(desc);
        }
    }
    None
}

pub fn try_apply_bash_descriptions(script: &str, root_cmd: &Command) -> Option<String> {
    if !script.contains("opts=") || !script.contains("compgen -W") {
        return None;
    }

    let mut lines = Vec::new();
    let mut current_cmd_path: Vec<String> = Vec::new();
    let mut modified_any = false;

    for line in script.lines() {
        let trimmed = line.trim();
        if trimmed.ends_with(')') && !trimmed.starts_with('*') && !trimmed.starts_with(';') {
            let pattern = trimmed.trim_end_matches(')').trim();
            if pattern.contains("__") || pattern == root_cmd.name.as_deref().unwrap_or("") {
                current_cmd_path = pattern.split("__").map(|s| s.to_string()).collect();
            }
        }

        if trimmed == "opts=\"\"" {
            let indent_len = line.len() - line.trim_start().len();
            let indent = &line[..indent_len];
            lines.push(format!("{}opts=()", indent));
            modified_any = true;
            continue;
        }

        if trimmed.starts_with("opts=\"") && trimmed.ends_with('"') && trimmed.len() >= 7 {
            let indent_len = line.len() - line.trim_start().len();
            let indent = &line[..indent_len];
            let content = &trimmed[6..trimmed.len() - 1];

            if !content.is_empty() {
                let tokens: Vec<&str> = content.split_whitespace().collect();
                let mut array_elements = Vec::new();

                for token in tokens {
                    let desc = find_description_for_token(token, &current_cmd_path, root_cmd);
                    let clean_desc = desc.unwrap_or_default().replace(['\n', '\r', '\t'], " ");
                    let clean_desc = clean_desc.trim();
                    let escaped_element = format!("{}\t{}", token, clean_desc).replace('"', "\\\"");
                    array_elements.push(format!("\"{}\"", escaped_element));
                }

                let new_line = format!("{}opts=({})", indent, array_elements.join(" "));
                lines.push(new_line);
                modified_any = true;
                continue;
            }
        }

        if trimmed.contains("compgen -W \"${opts}\"")
            || trimmed.contains("compgen -W \"${opts[*]}\"")
        {
            let indent_len = line.len() - line.trim_start().len();
            let indent = &line[..indent_len];
            lines.push(format!("{}COMPREPLY=()", indent));
            lines.push(format!("{}for item in \"${{opts[@]}}\"; do", indent));
            lines.push(format!(
                "{}    if [[ \"$item\" == \"$cur\"* ]]; then",
                indent
            ));
            lines.push(format!("{}        COMPREPLY+=(\"$item\")", indent));
            lines.push(format!("{}    fi", indent));
            lines.push(format!("{}done", indent));
            modified_any = true;
            continue;
        }

        lines.push(line.to_string());
    }

    if !modified_any {
        return None;
    }

    let mut result = lines.join("\n");
    if script.ends_with('\n') {
        result.push('\n');
    }
    Some(result)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::parse_help;

    #[test]
    fn test_bash_with_descriptions_output() {
        const HELP: &str = r#"Usage: greet [OPTIONS]

Options:
  -n, --name <NAME>  Name to greet
  -h, --help         Print help
"#;
        let cmd = parse_help(HELP);
        let script = try_apply_bash_descriptions(
            r#"_greet() {
    opts="-n --name -h --help"
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
}"#,
            &cmd,
        )
        .expect("should transform expected format");
        assert!(script.contains(
            "opts=(\"-n\tName to greet\" \"--name\tName to greet\" \"-h\tPrint help\" \"--help\tPrint help\")"
        ));

        // Test fallback when script format does not match expected format
        let fallback = try_apply_bash_descriptions("echo 'custom bash script'", &cmd);
        assert!(fallback.is_none());
    }
}
