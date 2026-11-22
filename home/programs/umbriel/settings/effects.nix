{
  # Directory include so shader.glsl is copied next to effect.toml.
  include.files = [
    "${../shaders/spectrum}/effect.toml"
  ];

  effects.border = "spectrum";
}
