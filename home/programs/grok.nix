# Home-wide Grok Build binary (wrapped packages.grok from the Grok definition repo).
# Does not manage ~/.grok/config.toml — see inputs.grok.homeManagerModules.
{ inputs, ... }:
{
  imports = [ inputs.grok.homeManagerModules.default ];
}
