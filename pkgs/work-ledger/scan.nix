{
  writeShellApplication,
  python3,
  jujutsu,
  git,
  coreutils,
}:
writeShellApplication {
  name = "work-ledger-scan";
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
      echo "work-ledger-scan: missing $script (clone agent-definition repo?)" >&2
      exit 1
    fi
    exec ${python3}/bin/python3 "$script" scan
  '';
}
