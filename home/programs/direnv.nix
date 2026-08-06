{ ... }:
{
  # Auto-load project flakes on cd; nix-direnv GC-roots the shell so
  # `nh clean` / store GC does not force a full re-fetch of Grok every time.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # Quieter prompts; still prints load/unload.
    config = {
      global = {
        hide_env_diff = true;
        # Flake shells (llm-agents) can take a while the first time.
        warn_timeout = "1m";
      };
    };
  };
}
