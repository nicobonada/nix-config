{
  writeShellApplication,
  python3,
  jujutsu,
  git,
  coreutils,
}:
# Thin wrapper: store python3 + live checkout script under $HOME/src/grok.
# No ambient python3 required. Fails loudly if the agent repo is missing.
writeShellApplication {
  name = "work-ledger";
  runtimeInputs = [
    python3
    jujutsu
    git
    coreutils
  ];
  text = ''
    set -euo pipefail
    script="$HOME/src/grok/scripts/work-ledger"
    if [[ ! -f $script ]]; then
      echo "work-ledger: missing $script (clone agent-definition repo?)" >&2
      exit 1
    fi
    exec ${python3}/bin/python3 "$script" "$@"
  '';
}
