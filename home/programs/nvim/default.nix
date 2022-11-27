{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # language servers
      nodePackages.bash-language-server
      nodePackages.pyright
      nil
      sumneko-lua-language-server
      # null-ls
      nixpkgs-fmt
      stylua
      statix
    ];

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      tokyonight-nvim

      dressing-nvim
      gitsigns-nvim
      i3config-vim
      legendary-nvim
      mini-nvim
      nvim-colorizer-lua
      nvim-web-devicons
      vim-fish
      vim-matchup
      which-key-nvim

      # telescope
      telescope-nvim
      telescope-file-browser-nvim

      # lsp stuff
      nvim-lspconfig
      null-ls-nvim
      lspkind-nvim

      # completion
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-nvim-lsp-signature-help
      nvim-cmp
      luasnip
      cmp_luasnip

      nvim-treesitter.withAllGrammars
    ];
  };

  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."stylua".source = ./stylua;
}
