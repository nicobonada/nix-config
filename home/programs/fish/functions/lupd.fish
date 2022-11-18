function lupd --argument-names 'lockfile' --description "Last flake.lock update"
    if test -z "$lockfile"
        set lockfile ~/nix-config/flake.lock
    end
    set last_update (stat -c '%y' $lockfile | awk '{print $1}')
    echo "Last update --> "$last_update
    echo "Today       --> "(date +%F)
end
