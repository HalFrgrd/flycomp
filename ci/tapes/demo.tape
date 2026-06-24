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
Type "flycomp grep --output bash > grep_completion.sh"
Enter
Sleep 1000ms
Show
Type "bat grep_completion.sh"
Sleep 500ms
Enter
Sleep 2000ms

# Scroll down slowly
Down@180ms 50
Sleep 1500ms

# Exit bat
Type "q"

Hide
Sleep 100ms
Type "clear"
Enter
Sleep 100ms
Show

Sleep 1000ms

# Output JSON structure of rm command options and view in bat with syntax highlighting
Hide
Type "flycomp rm --output json > rm_completion.json"
Enter
Sleep 1000ms
Show
Type "bat rm_completion.json"
Sleep 500ms
Enter
Sleep 2000ms

# Scroll down slowly
Down@180ms 50
Sleep 1500ms

# Exit bat
Type "q"
Sleep 2000ms
