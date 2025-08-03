{ pkgs, ... }:
{

  # prevent nixd from bloating the lsp.log file
  home.sessionVariables.NIXD_FLAGS = "-log=error";

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # language servers
      bash-language-server
      pyright
      nil
      nixd
      lua-language-server
    ];

    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim

      dressing-nvim
      gitsigns-nvim
      mini-nvim
      nvim-colorizer-lua
      nvim-web-devicons
      vim-fish
      vim-matchup
      which-key-nvim
      vim-jjdescription

      # telescope
      telescope-nvim
      telescope-file-browser-nvim

      # # completion
      # TODO: set up blink.nvim

      nvim-treesitter.withAllGrammars
    ];
  };

  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/lsp".source = ./lsp;
  xdg.configFile."stylua".source = ./stylua;
}
