{ lib, pkgs, ... }:
{
  programs.fish.functions = {
    addr = {
      description = "ip address";
      body = /* fish */''
        ip --brief -4 address | \
        awk '$1 != "lo" {print $1,$3}' | \
        column -t -s ' /' | \
        ${lib.getExe pkgs.cowsay} -dn
      '';
    };

    fish_user_key_bindings = /* fish */ ''
      bind alt-k 'commandline -a " >/dev/null 2>&1 &"'
    '';

    lupd = {
      description = "Last flake.lock update";
      argumentNames = "lockfile";
      body = /* fish */ ''
        if test -z "$lockfile"
          set lockfile ~/nix-config/flake.lock
        end
        set last_update (stat -c '%y' $lockfile | awk '{print $1}')
        echo "Last update --> "$last_update
        echo "Today       --> "(date +%F)
      '';
    };

    fish_prompt = {
      description = "Write out the prompt";
      body = /* fish */ ''
        if test -n "$IN_NIX_SHELL"
            echo -n "<nix-shell> "
        end

        switch $USER
        case root
            set_color red
            echo -n '# '
        case '*'
            set_color green
            echo -n '$ '
        end

        set_color normal
      '';
    };

    nupd = {
      description = "update system and home";
      body = /* fish */ ''
        nh os switch --update ~/nix-config
        if test (nmcli networking connectivity check) = 'full'
            nh home switch ~/nix-config
        end
      '';
    };
  };
}
