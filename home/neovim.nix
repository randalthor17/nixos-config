{ pkgs, inputs, ... }:

{
  imports = [ inputs.lazyvim.homeManagerModules.default ];

  programs.lazyvim = {
    enable = true;

    extras = {
      lang.nix.enable = true;
      lang.markdown.enable = true;
      lang.clangd.enable = true;
      lang.go = {
        enable = true;
        installDependencies = true; # gopls, gofumpt, goimports, impl, golangci-lint, ...
        installRuntimeDependencies = true; # go toolchain
      };
    };

    extraPackages = with pkgs; [
      # Any additional tools not covered by the module
      neovide
      markdownlint-cli2
      kdlfmt
      clang-tools
      gotools # goimports (lang.go formatter; not pulled in by installDependencies)

      # :checkhealth fixes
      tree-sitter # nvim-treesitter parser builds
      glib # `gio` for snacks explorer trash
      ghostscript # `gs` for snacks PDF previews
      tectonic # snacks LaTeX math rendering
    ];
    # base46 themes, pinned via the flake input and loaded from the store (`dir`).
    # Loaded eagerly: the store dir name does not match the plugin name, so lazy.nvim
    # cannot auto-load it on `require("base46")` (same issue as trouble below).
    # For a Dux-following theme use "dms" (Theme & Apps -> neovim) instead.
    plugins.base46 = ''
      return {
        { dir = "${inputs.base46}", name = "base46", priority = 1000, opts = {} },
        { "LazyVim/LazyVim", opts = { colorscheme = "base46-material-darker" } },
      }
    '';

    # lualine's symbol breadcrumb require()s trouble before it is loaded. lazy.nvim
    # then fails to map the module to its plugin (the dev-path dir is
    # "folke--trouble.nvim" but the plugin is "trouble.nvim"), so trouble never
    # reaches the rtp or runs setup and its sources never register.
    # Declaring it as a dependency makes lazy load it properly first.
    # noice can't run when the UI draws its own cmdline (ext_cmdline GUIs).
    # GUIs attach via --embed before config is sourced, so list_uis() is valid here.
    plugins.noice-gui = ''
      return {
        "folke/noice.nvim",
        cond = function()
          if vim.g.neovide then
            return false
          end
          for _, ui in ipairs(vim.api.nvim_list_uis()) do
            if ui.ext_cmdline then
              return false
            end
          end
          return true
        end,
      }
    '';

    # Same dev-path naming issue: the dashboard's "Restore Session" require()s
    # persistence before lazy.nvim ran its setup (opts.dir nil -> E5108).
    # Load it at startup so setup() always runs first.
    plugins.persistence-eager = ''
      return {
        "folke/persistence.nvim",
        lazy = false,
      }
    '';

    plugins.lualine-trouble = ''
      return {
        "nvim-lualine/lualine.nvim",
        dependencies = { "folke/trouble.nvim" },
      }
    '';
  };

  # Keep Neovide enabled globally since lazyvim-nix focuses on nvim
  programs.neovide.enable = true;
  programs.lazygit.enable = true;

  xdg.configFile."nvim/lua/config/options.lua".text = ''
    -- Your existing LazyVim options can go here

    if vim.g.neovide then
      vim.o.guifont = "GoogleSansCode Nerd Font:h14"
      -- Turn off the graphical top bar/title bar for Window Managers
      vim.g.neovide_decorations = false
    end

  '';
}
