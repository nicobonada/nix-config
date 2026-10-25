function grok --description 'attach the shpool grok session for this directory'
    # Subcommands and one-shot flags stay in this terminal.
    set -l passthrough \
        agent clone completions dashboard doctor du export help inspect \
        leader login logout mcp memory models plugin sessions setup trace \
        update usage version v worker worktree wrap
    if set -q argv[1]; and contains -- $argv[1] $passthrough
        command grok $argv
        return
    end
    for arg in $argv
        switch $arg
            case -h --help -v --version -p --single --prompt-file --prompt-json
                command grok $argv
                return
        end
    end

    # Path under $HOME with slashes turned into dashes. $HOME is "home".
    set -l rel (string replace -r -- '^'"$HOME"'/?' '' $PWD)
    if test -z "$rel"
        set rel home
    end
    set -l slug (string replace -a -- / - $rel)
    set slug (string replace -ra -- '[^A-Za-z0-9._-]' - $slug)
    set -l name "grok-$slug"

    # fish `exec` looks up a process. `exec command grok` tries to run
    # a binary named `command` and the session exits 127.
    set -l grok_bin $GROK_BIN
    if test -z "$grok_bin"
        set grok_bin (command --search grok)
    end
    if test -z "$grok_bin"
        echo "grok: binary not on PATH" >&2
        return 1
    end

    # -c applies only when the session is created; a later attach
    # keeps the running TUI. Close the window to detach.
    # `shpool kill <name>` ends the TUI.
    # Inner exec makes grok the session process. Attach stays a
    # child of this shell so quitting grok leaves the prompt.
    set -l inner "exec $grok_bin"
    if set -q argv[1]
        set inner "$inner $(string join ' ' -- (string escape -- $argv))"
    end
    shpool attach -f -d . -c "fish -lic $(string escape -- $inner)" $name
end
