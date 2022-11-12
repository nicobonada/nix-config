function lupd --description "Last nix=channel update"
    set channel "/nix/var/nix/profiles/per-user/root/channels"
    set last_update (stat -c '%y' $channel | awk '{print $1}')
    echo "Last update --> "$last_update
    echo "Today       --> "(date +%F)
end
