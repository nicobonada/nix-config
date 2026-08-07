{ inputs, pkgs, config, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      viAlias  = false;
      vimAlias = true;

      clipboard = {
        enable = true;
        providers.wl-copy = {
          enable = true;
          package = pkgs.wl-clipboard-rs;
        };
      };

      autocomplete.blink-cmp = {
        enable = true;
        friendly-snippets.enable = true;
        setupOpts.cmdline = {
          keymap.preset = "cmdline";
          completion.menu.auto_show = true;
        };
      };

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
        python = {
          enable = true;
          # Astral stack: ty (types) + ruff (lint LSP + format/fix via conform).
          lsp.servers = [ "ty" "ruff" ];
          # ruff-fix (safe autofixes) then ruff format — replaces black.
          format.type = [ "ruff-fix" "ruff" ];
          # mypy via nvim-lint is redundant next to ty
          extraDiagnostics.enable = false;
        };


        nix.enable    = true;
        nix.lsp.servers = [ "nixd" ];

        # fish-lsp + fish_indent + treesitter; lsp/format follow vim.lsp / enableFormat
        fish.enable = true;

        # yaml-language-server + prettier + treesitter
        yaml.enable = true;
      };

      # grammars without a languages.* module
      treesitter.grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        kdl
        udev
      ];

      ui.noice.enable = true;

      mini = {
        align.enable          = true;
        align.setupOpts       = { mappings = { start_with_preview = "<cr>"; }; };
        bufremove.enable      = true;
        icons.enable          = true;
        indentscope.enable    = true;
        indentscope.setupOpts = { symbol = "▏"; };
        snippets.enable       = true;
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
        # noice owns the message UI; height 2 just wastes a status row
        cmdheight     = 1;
        fillchars     = "vert:\ ,diff:─";
        list          = true;
        listchars     = "tab:│\ ,trail:·,extends:…,nbsp:‗";
        scrolloff     = 3;
        sidescrolloff = 2;
        virtualedit   = "block,onemore";
      };

      extraPlugins = {
        kanagawa-nvim = {
          package = pkgs.vimPlugins.kanagawa-nvim;
        };
      };

      luaConfigRC.colorscheme = /* lua */ ''
          local cmd = vim.cmd
          cmd.colorscheme("kanagawa-wave")
        '';

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
        local aug = vim.api.nvim_create_augroup("UserNvim", { clear = true })

        vim.api.nvim_create_autocmd("TextYankPost", {
          group = aug,
          callback = function()
            vim.highlight.on_yank({ timeout = 300 })
          end,
        })

        -- :he last-position-jump
        vim.api.nvim_create_autocmd("BufReadPost", {
          group = aug,
          callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local line_count = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= line_count then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end,
        })

        -- nix indent (commentstring comes from filetype/treesitter)
        vim.api.nvim_create_autocmd("FileType", {
          group = aug,
          pattern = "nix",
          callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.shiftwidth = 2
            vim.opt_local.softtabstop = 2
          end,
        })
        '';
    };
  };
}
