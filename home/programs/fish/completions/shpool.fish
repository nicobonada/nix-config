# Global flags before the subcommand, forwarded into `list --json` so
# tab works against a non-default socket or config.
function __shpool_global_args
    set -l words (commandline -opc)
    set -e words[1]
    set -l globals
    set -l expects_value 0

    for word in $words
        if test $expects_value -eq 1
            set -a globals $word
            set expects_value 0
            continue
        end

        switch $word
            case attach detach kill list events daemon var set-log-level version help
                break
            case -l --log-file -s --socket -c --config-file
                set -a globals $word
                set expects_value 1
            case -v --verbose -d --daemonize -D --no-daemonize
                set -a globals $word
        end
    end

    printf '%s\n' $globals
end

function __shpool_sessions
    set -l globals (__shpool_global_args)
    command shpool $globals list --json 2>/dev/null \
        | jq -r '.sessions[]? | "\(.name)\t\(.status)"' \
        2>/dev/null
end

function __shpool_var_needs_subcommand
    __fish_seen_subcommand_from var
    and not __fish_seen_subcommand_from list get set unset help
end

# Attach takes one session name. Skip flags that consume a value.
function __shpool_needs_attach_session
    set -l words (commandline -opc)
    set -e words[1]
    set -l expects_value 0
    set -l seen_attach 0
    set -l positional_count 0

    for word in $words
        if test $expects_value -eq 1
            set expects_value 0
            continue
        end

        if test $seen_attach -eq 0
            switch $word
                case attach
                    set seen_attach 1
                case -l --log-file -s --socket -c --config-file
                    set expects_value 1
            end
            continue
        end

        switch $word
            case --ttl --cmd -c --dir -d --start-cmd -s
                set expects_value 1
            case -f --force -b --background -h --help
            case '-*'
            case '*'
                set positional_count (math $positional_count + 1)
        end
    end

    test $seen_attach -eq 1; and test $positional_count -eq 0
end

function __shpool_needs_log_level
    set -l words (commandline -opc)
    set -e words[1]
    set -l expects_value 0
    set -l seen_command 0
    set -l value_count 0

    for word in $words
        if test $expects_value -eq 1
            set expects_value 0
            continue
        end

        if test $seen_command -eq 0
            switch $word
                case set-log-level
                    set seen_command 1
                case -l --log-file -s --socket -c --config-file
                    set expects_value 1
            end
            continue
        end

        switch $word
            case -h --help
            case '-*'
            case '*'
                set value_count (math $value_count + 1)
        end
    end

    test $seen_command -eq 1; and test $value_count -eq 0
end

complete -c shpool -f
complete -c shpool -s h -l help -d 'Print help'
complete -c shpool -s l -l log-file -r -F -d 'Write logs to this file'
complete -c shpool -s v -l verbose -d 'More daemon logs'
complete -c shpool -n __fish_use_subcommand -s s -l socket -r -F -d 'Unix socket path'
complete -c shpool -n __fish_use_subcommand -s c -l config-file -r -F -d 'TOML config file'
complete -c shpool -n __fish_use_subcommand -s d -l daemonize -d 'Start a daemon if none is running'
complete -c shpool -n __fish_use_subcommand -s D -l no-daemonize -d 'Do not auto-start a daemon'

complete -c shpool -n __fish_use_subcommand -a attach -d 'Create or attach to a session'
complete -c shpool -n __fish_use_subcommand -a detach -d 'Detach without closing the shell'
complete -c shpool -n __fish_use_subcommand -a kill -d 'Hang up and kill a session'
complete -c shpool -n __fish_use_subcommand -a list -d 'List running sessions'
complete -c shpool -n __fish_use_subcommand -a events -d 'Subscribe to the daemon event stream'
complete -c shpool -n __fish_use_subcommand -a daemon -d 'Run the session pool daemon'
complete -c shpool -n __fish_use_subcommand -a var -d 'Template variables'
complete -c shpool -n __fish_use_subcommand -a set-log-level -d 'Change daemon log level'
complete -c shpool -n __fish_use_subcommand -a version -d 'Print version'
complete -c shpool -n __fish_use_subcommand -a help -d 'Print help'

complete -c shpool -n '__fish_seen_subcommand_from attach' -s f -l force -d 'Steal an attached tty'
complete -c shpool -n '__fish_seen_subcommand_from attach' -s b -l background -d 'Attach then detach immediately'
complete -c shpool -n '__fish_seen_subcommand_from attach' -l ttl -r -d 'Kill the session after this duration'
complete -c shpool -n '__fish_seen_subcommand_from attach' -s c -l cmd -r -d 'Command instead of the default shell'
complete -c shpool -n '__fish_seen_subcommand_from attach' -s d -l dir -r -a '(__fish_complete_directories)' -d 'Start directory (. for pwd)'
complete -c shpool -n '__fish_seen_subcommand_from attach' -s s -l start-cmd -r -d 'Command to run inside the new shell'
complete -c shpool -n __shpool_needs_attach_session -a '(__shpool_sessions)'
complete -c shpool -n '__fish_seen_subcommand_from kill detach' -a '(__shpool_sessions)'

complete -c shpool -n '__fish_seen_subcommand_from list' -s j -l json -d 'JSON output'

complete -c shpool -n __shpool_needs_log_level \
    -a 'off error warn info debug trace'

complete -c shpool -n __shpool_var_needs_subcommand -a list -d 'Dump variables as JSON'
complete -c shpool -n __shpool_var_needs_subcommand -a get -d 'Get a variable'
complete -c shpool -n __shpool_var_needs_subcommand -a set -d 'Set a variable'
complete -c shpool -n __shpool_var_needs_subcommand -a unset -d 'Remove a variable'
complete -c shpool -n __shpool_var_needs_subcommand -a help -d 'Print help'
