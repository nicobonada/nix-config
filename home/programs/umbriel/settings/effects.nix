{ inputs }:
{
  # Store path because config.toml is a store symlink.
  include.files = [
    "${inputs.community-umbriel-shaders}/border/spectrum/effect.toml"
  ];

  effects.border = "spectrum";
}
