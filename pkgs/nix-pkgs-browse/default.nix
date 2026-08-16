{
  writeShellApplication,
  fzf,
  coreutils,
  findutils,
  gnugrep,
  gawk,
}:
writeShellApplication {
  name = "nix-pkgs-browse";
  runtimeInputs = [
    fzf
    coreutils
    findutils
    gnugrep
    gawk
  ];
  text = ''
        set -euo pipefail

        strip_hash() {
          local base="''${1##*/}"
          if [[ "$base" =~ ^[0-9a-z]{32}-(.+)$ ]]; then
            printf '%s\n' "''${BASH_REMATCH[1]}"
          else
            printf '%s\n' "$base"
          fi
        }

        profile_home() {
          local state="''${XDG_STATE_HOME:-$HOME/.local/state}"
          local p="$state/nix/profiles/home-manager/home-path"
          if [[ -e "$p" ]]; then
            readlink -f "$p"
          elif [[ -e "$HOME/.nix-profile" ]]; then
            readlink -f "$HOME/.nix-profile"
          fi
        }

        profile_system() {
          if [[ -e /run/current-system/sw ]]; then
            readlink -f /run/current-system/sw
          fi
        }

        # Lines: store-path<TAB>label
        list_from_root() {
          local root="$1"
          local label="$2"
          local p name
          while IFS= read -r p; do
            [[ -n "$p" ]] || continue
            name="$(strip_hash "$p")"
            printf '%s\t[%s] %s\n' "$p" "$label" "$name"
          done < <(nix-store -q --references "$root" 2>/dev/null | sort)
        }

        preview() {
          local path="''${1:-}"
          if [[ -z "$path" || ! -e "$path" ]]; then
            echo "No store path for this entry."
            return 0
          fi

          printf 'path:    %s\n' "$path"
          printf 'name:    %s\n' "$(strip_hash "$path")"
          echo

          if command -v nix >/dev/null 2>&1; then
            # path-info prints: <path> <size> <unit> <closure> <unit>
            nix path-info --size --closure-size --human-readable "$path" 2>/dev/null \
              | awk '{
                  printf "size:    %s %s\n", $2, $3
                  if (NF >= 5) printf "closure: %s %s\n", $4, $5
                }'
          else
            echo "size:    (nix not on PATH)"
          fi

          echo
          if [[ -d "$path/bin" ]]; then
            echo "binaries:"
            local n
            n="$(find "$path/bin" -mindepth 1 -maxdepth 1 -printf '%f\n' 2>/dev/null | wc -l | tr -d ' ')"
            find "$path/bin" -mindepth 1 -maxdepth 1 -printf '%f\n' 2>/dev/null \
              | sort \
              | head -n 40 \
              | sed 's/^/  /'
            if [[ "''${n:-0}" -gt 40 ]]; then
              echo "  … ($n total)"
            fi
          else
            echo "binaries: (none)"
          fi

          echo
          local refs
          refs="$(nix-store -q --references "$path" 2>/dev/null | wc -l | tr -d ' ')"
          printf 'direct references: %s\n' "''${refs:-0}"
        }

        usage() {
          cat <<'EOF' >&2
    usage: nix-pkgs-browse [home|system|all]

    Interactively browse packages in the home-manager and/or NixOS
    system profiles (fzf). Preview shows store path, sizes, and binaries.

    On accept, prints the short package name (store name without hash).
    EOF
          exit 2
        }

        if [[ "''${1:-}" == --preview ]]; then
          preview "''${2:-}"
          exit 0
        fi

        scope="''${1:-all}"
        home_root="$(profile_home || true)"
        system_root="$(profile_system || true)"

        list_entries() {
          case "$scope" in
            home)
              if [[ -z "''${home_root:-}" ]]; then
                echo "nix-pkgs-browse: no home-manager profile found" >&2
                exit 1
              fi
              list_from_root "$home_root" home
              ;;
            system)
              if [[ -z "''${system_root:-}" ]]; then
                echo "nix-pkgs-browse: no /run/current-system/sw found" >&2
                exit 1
              fi
              list_from_root "$system_root" system
              ;;
            all)
              if [[ -n "''${home_root:-}" ]]; then
                list_from_root "$home_root" home
              fi
              if [[ -n "''${system_root:-}" ]]; then
                list_from_root "$system_root" system
              fi
              if [[ -z "''${home_root:-}" && -z "''${system_root:-}" ]]; then
                echo "nix-pkgs-browse: no home or system profile found" >&2
                exit 1
              fi
              ;;
            -h | --help) usage ;;
            *) usage ;;
          esac
        }

        self="$(readlink -f "$0")"
        selection="$(
          list_entries | fzf \
            --prompt='package> ' \
            --height=80% \
            --reverse \
            --border \
            --delimiter=$'\t' \
            --with-nth=2.. \
            --preview="'$self' --preview {1}" \
            --preview-window=right:50%:wrap \
            --header='enter: print name · esc: cancel · tab: home|system|all via arg' \
            || true
        )"

        if [[ -z "$selection" ]]; then
          exit 0
        fi

        # selection is path<TAB>[scope] name
        label="''${selection#*$'\t'}"
        name="''${label#\[*\] }"
        printf '%s\n' "$name"
  '';
}
