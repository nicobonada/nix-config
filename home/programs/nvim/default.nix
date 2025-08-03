{ inputs, pkgs, config, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      viAlias  = false;
      vimAlias = true;

      theme = {
        enable = true;
        name = "catppuccin";
        style = config.catppuccin.flavor;
      };

      autocomplete.blink-cmp.enable = true;
      lsp.enable = true;
      formatter.conform-nvim.enable = true;
      binds.whichKey.enable = true;
      git.gitsigns.enable = true;

      telescope.enable = true;

      utility = {
        sleuth.enable = true;
        yazi-nvim.enable = true;
        yazi-nvim.setupOpts.open_for_directories = true;
      };

      languages = {
        enableExtraDiagnostics = true;
        enableFormat           = true;
        enableTreesitter       = true;

        bash.enable   = true;
        lua.enable    = true;
        python.enable = true;

        nix.enable    = true;
        nix.lsp.servers = [ "nixd" ];
      };

      treesitter.grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        fish
        udev
        yaml
      ];

      ui.noice.enable = true;

      mini = {
        align.enable          = true;
        align.setupOpts       = { mappings = { start_with_preview = "<cr>"; }; };
        bufremove.enable      = true;
        icons.enable          = true;
        indentscope.enable    = true;
        indentscope.setupOpts = { symbol = "▏"; };
        starter.enable        = true;
        statusline.enable     = true;
        tabline.enable        = true;
      };

      luaConfigRC.bufremove = /* lua */ ''
        vim.api.nvim_create_user_command('BD',
          function()
            MiniBufremove.delete()
          end, {}
        )
        '';

      globals.mapleader = ",";

      undoFile.enable = true;

      hideSearchHighlight = true;
      searchCase = "smart";

      options = {
        tabstop       = 4;
        shiftwidth    = 4;
        softtabstop   = 4;
        expandtab     = true;

        textwidth     = 78;
        wrap          = false;
        whichwrap     = "b,s,<,>,[,]";
        autowrite     = true;
        cmdheight     = 2;
        fillchars     = "vert:\ ,diff:─";
        list          = true;
        listchars     = "tab:│\ ,trail:·,extends:…,nbsp:‗";
        scrolloff     = 3;
        sidescrolloff = 2;
        virtualedit   = "block,onemore";
      };

      luaConfigRC.keymaps = /* lua */ ''
        local kmap = vim.keymap.set

        kmap('n', '<leader>;', ':bprevious<cr>')
        kmap('n', '<leader>.', ':bnext<cr>')

        kmap('n', '<c-c>', '<esc>:set cursorline! cursorcolumn!<cr>', { silent = true })

        kmap('n', '<leader>p', ':pu  +<cr>', { silent = true })
        kmap('n', '<leader>P', ':pu! +<cr>', { silent = true })

        kmap('n', '<Leader>s', ':setlocal spell! spelllang=en_us<CR>', { silent = true })

        kmap('i', '<bs>', '<c-g>u<bs>')
        kmap('i', '<cr>', '<c-g>u<cr>')
        kmap('i', '<del>', '<c-g>u<del>')
        kmap('i', '<c-w>', '<c-g>u<c-w>')

        kmap('n', '<nl>', 'i<cr><esc>')
        '';

      luaConfigRC.autocommands = /* lua */ ''
        local cmd = vim.cmd

        cmd [[autocmd TextYankPost * silent! lua vim.highlight.on_yank {timeout=300}]]
        cmd [[autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /]]
        -- see :he last-position-jump
        cmd [[autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]]
        cmd [[autocmd BufEnter *.nix setlocal tabstop=2 shiftwidth=2 softtabstop=2 commentstring=#\ %s]]
        '';
    };
  };
}
