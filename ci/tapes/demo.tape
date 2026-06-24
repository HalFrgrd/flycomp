Output demo.gif
Output demo.svg

Source demo_settings.tape
Source demo_setup.tape

# Type the first command to show help
Type "flycomp --help"
Sleep 500ms
Enter
Sleep 4000ms

# Clear screen
Type "clear"
Enter
Sleep 500ms

# Synthesize completions for grep in bash format and view in bat with syntax highlighting
Hide
Sleep 100ms
Type "flycomp grep --output bash > grep_completion.sh && clear"
Enter
Sleep 1000ms
Show

Type "flycomp grep --output bash | bat --language bash"
Sleep 500ms
Enter
Sleep 2000ms

# Scroll down slowly
Down@160ms 70
Sleep 1000ms

Hide
# Exit bat
Type "q"

Sleep 100ms
Type "clear"
Enter
Sleep 100ms
Show

Sleep 1000ms

# Output JSON structure of evp command options and view in bat with syntax highlighting
Hide
Type "flycomp evp --output json > evp_completion.json && clear"
Enter
Sleep 1000ms
Show

Type "flycomp evp --output json | bat --language json"
Sleep 500ms
Enter
Sleep 2000ms

# Scroll down slowly
Down@160ms 70
Sleep 1500ms

# Exit bat
Type "q"
Sleep 2000ms
