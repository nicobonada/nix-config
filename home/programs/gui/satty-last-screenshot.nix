{ pkgs, config, ... }:

let
  satty-last-screenshot = pkgs.writeShellApplication {
    name = "satty-last-screenshot";
    runtimeInputs = with pkgs; [
      satty
      fd
      coreutils
      wl-clipboard-rs
    ];
    text = ''
      dir="${config.home.homeDirectory}/Pictures/Screenshots"
      # -X ls -t: newest match first (batch exec only runs if fd found files)
      latest="$(
        fd -e png -e jpg -e jpeg -e webp -t f -d 1 . "$dir" -X ls -t \
          | head -n1
      )"
      if [ -z "$latest" ]; then
        echo "satty-last-screenshot: no images in $dir" >&2
        exit 1
      fi
      exec satty \
        --filename "$latest" \
        --output-filename "$latest" \
        --copy-command wl-copy \
        --early-exit \
        --actions-on-enter save-to-clipboard,save-to-file,exit
    '';
  };
in
{
  home.packages = [ satty-last-screenshot ];
}
