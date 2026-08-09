# Home-wide Grok Build binary (wrapped packages.grok from grok-config).
# Does not manage ~/.grok/config.toml — see grok-config homeManagerModules.
{ inputs, ... }:
{
  imports = [ inputs.grok-config.homeManagerModules.default ];
}
