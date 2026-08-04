function lupd --description 'Last flake.lock update' --argument-names lockfile
    if test -z "$lockfile"
        set lockfile ~/nix-config/flake.lock
    end
    set last_update (stat -c '%y' $lockfile | awk '{print $1}')
    echo "Last update --> $last_update"
    echo "Today       --> "(date +%F)
end
