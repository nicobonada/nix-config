# Wrapped Grok Build for interactive PATH (home-manager).
# Upstream binary: llm-agents.packages.grok. Agent-apps only on this process PATH.
{
  pkgs,
  grok-unwrapped,
}:
let
  inherit (pkgs)
    lib
    writeShellApplication
    symlinkJoin
    runCommand
    coreutils
    hostname
    ;
  grokExe = lib.getExe grok-unwrapped;
  agentApps = import ./agent-apps.nix pkgs;
  grokBin = writeShellApplication {
    name = "grok";
    # Exec upstream by absolute path so this wrapper is not shadowed.
    runtimeInputs = agentApps ++ [
      coreutils
      hostname
    ];
    text = ''
      ${builtins.readFile ./load-runtime-env.sh}
      exec ${grokExe} "$@"
    '';
  };
  # clap top-level complete omits -f; fish would also offer cwd files.
  grokFishCompletions = runCommand "grok-fish-completions" { } ''
    mkdir -p $out/share/fish/vendor_completions.d
    {
      echo '# clap top-level complete omits -f; disable default file completion.'
      echo 'complete -c grok -f'
      ${grokExe} completions fish
    } > $out/share/fish/vendor_completions.d/grok.fish
  '';
in
symlinkJoin {
  name = "grok";
  paths = [
    grokBin
    grokFishCompletions
  ];
  meta = {
    mainProgram = "grok";
    description = "Grok Build (agent-apps PATH + runtime env)";
  };
}
