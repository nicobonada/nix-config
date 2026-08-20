# Packages on PATH for Grok tool shells only (not the interactive user shell).
# Add a package here when the agent needs it often; one-offs: nix shell nixpkgs#pkg -c …
# Prefer listing anything portable scripts assume so agent shells are self-contained.
pkgs: with pkgs; [
  # scripts/trilium-save-note — MD → HTML for ETAPI text notes
  (python3.withPackages (ps: [ ps.markdown ]))
  jq
  unzip
  (callPackage ./agent-ssh.nix { })

  # scripts/{pull,publish} — fish shebang + jj/git VCS
  fish
  jujutsu
  git

  # HTTP / GitHub (agent + hooks; curl not always on minimal PATH)
  curl
  gh

  # shell.md preferences + file probes
  fd
  ripgrep
  file

  # classic image pipeline (rules/capture-recurring.md) — identify / magick
  imagemagick

  # scripts/nvd-if-changed — store-path closure diffs (informational, not a gate)
  nvd

  # Official Nix formatter (RFC 166). Run on touched .nix files before recording
  # (rules/nix.md). nvim is set to the same via nvf format.type.
  nixfmt
]
