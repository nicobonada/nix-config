{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  # Absolute path so nvim can spawn Grok even if PATH is thin (GUI launch).
  # Uses SuperGrok OAuth via ~/.grok/auth.json — not the metered XAI_API_KEY.
  grokBin = lib.getExe inputs.grok.packages.${pkgs.stdenv.hostPlatform.system}.grok;
in
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      viAlias = false;
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

      # Select → rewrite / chat in-buffer via Grok Build ACP (SuperGrok quota).
      # Not a second full TUI session; still hand-edit one-liners.
      assistant.codecompanion-nvim = {
        enable = true;
        setupOpts = {
          # Telescope is already enabled; use it for the action palette.
          display.action_palette.provider = "telescope";

          # Custom ACP adapter only — hide HTTP presets so API-key xAI is not the default.
          adapters = lib.mkLuaInline ''
            {
              acp = {
                opts = {
                  show_presets = false,
                },
                -- Grok Build over ACP; auth is the same OAuth session as `grok` TUI.
                grok = function()
                  local helpers = require("codecompanion.adapters.acp.helpers")
                  return {
                    name = "grok",
                    formatted_name = "Grok Build",
                    type = "acp",
                    roles = {
                      llm = "assistant",
                      user = "user",
                    },
                    commands = {
                      -- Permission prompts stay on (no --always-approve) for nvim-spawned agent.
                      default = {
                        ${lib.strings.escapeNixString grokBin},
                        "agent",
                        "stdio",
                      },
                      -- Optional: :CodeCompanionChat adapter=grok command=yolo for tool auto-approve.
                      yolo = {
                        ${lib.strings.escapeNixString grokBin},
                        "agent",
                        "--always-approve",
                        "stdio",
                      },
                    },
                    defaults = {
                      mcpServers = {},
                      -- Agent turns can run long; default 20s is too short.
                      timeout = 300000,
                    },
                    parameters = {
                      protocolVersion = 1,
                      clientCapabilities = {
                        fs = { readTextFile = true, writeTextFile = true },
                      },
                      clientInfo = {
                        name = "CodeCompanion.nvim",
                        version = "1.0.0",
                      },
                    },
                    handlers = {
                      setup = function(self)
                        return true
                      end,
                      -- Grok authenticates via ~/.grok/auth.json inside the agent process.
                      auth = function(self)
                        return true
                      end,
                      form_messages = function(self, messages, capabilities)
                        return helpers.form_messages(self, messages, capabilities)
                      end,
                      on_exit = function(self, code) end,
                    },
                  }
                end,
              },
            }
          '';

          interactions = {
            chat.adapter = "grok";
            inline.adapter = "grok";
          };
        };
      };

      utility = {
        sleuth.enable = true;
        yazi-nvim.enable = true;
        yazi-nvim.setupOpts.open_for_directories = true;
      };

      languages = {
        enableExtraDiagnostics = true;
        enableFormat = true;
        enableTreesitter = true;

        bash.enable = true;
        lua.enable = true;
        python = {
          enable = true;
          # Astral stack: ty (types) + ruff (lint LSP + format/fix via conform).
          lsp.servers = [
            "ty"
            "ruff"
          ];
          # ruff-fix (safe autofixes) then ruff format — replaces black.
          format.type = [
            "ruff-fix"
            "ruff"
          ];
          # mypy via nvim-lint is redundant next to ty
          extraDiagnostics.enable = false;
        };

        nix = {
          enable = true;
          lsp.servers = [ "nixd" ];
          # Official RFC 166 formatter. nvf default is still alejandra.
          format.type = [ "nixfmt" ];
        };

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
        align.enable = true;
        align.setupOpts = {
          mappings = {
            start_with_preview = "<cr>";
          };
        };
        bufremove.enable = true;
        icons.enable = true;
        indentscope.enable = true;
        indentscope.setupOpts = {
          symbol = "▏";
        };
        snippets.enable = true;
        starter.enable = true;
        statusline.enable = true;
        tabline.enable = true;
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
        tabstop = 4;
        shiftwidth = 4;
        softtabstop = 4;
        expandtab = true;

        textwidth = 78;
        wrap = false;
        whichwrap = "b,s,<,>,[,]";
        autowrite = true;
        # noice owns the message UI; height 2 just wastes a status row
        cmdheight = 1;
        fillchars = "vert:\ ,diff:─";
        list = true;
        listchars = "tab:│\ ,trail:·,extends:…,nbsp:‗";
        scrolloff = 3;
        sidescrolloff = 2;
        virtualedit = "block,onemore";
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

        -- CodeCompanion (Grok ACP): select-edit / chat without a full TUI session
        kmap({ 'n', 'v' }, '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', {
          silent = true,
          desc = 'CodeCompanion chat',
        })
        kmap({ 'n', 'v' }, '<leader>ca', '<cmd>CodeCompanionActions<cr>', {
          silent = true,
          desc = 'CodeCompanion actions',
        })
        -- Visual: prompt to rewrite the selection inline
        kmap('v', '<leader>ci', '<cmd>CodeCompanion<cr>', {
          silent = true,
          desc = 'CodeCompanion inline',
        })
        kmap('n', '<leader>ci', '<cmd>CodeCompanion<cr>', {
          silent = true,
          desc = 'CodeCompanion inline',
        })
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
