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

# Synthesize completions for grep in bash format
Type "flycomp grep --output bash | head -n 20"
Sleep 500ms
Enter
Sleep 4000ms

# Clear screen again
Type "clear"
Enter
Sleep 500ms

# Output JSON structure of rm command options
Type "flycomp rm --output json | head -n 20"
Sleep 500ms
Enter
Sleep 4000ms
