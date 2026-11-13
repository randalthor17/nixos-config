{ ... }:

{
  # niri itself is installed system-wide (modules/nixos/desktop.nix), so this module
  # only owns the config: no session units or portal config from home-manager.
  # `package` stays at its default so the generated config is validated at
  # build time (checkConfig runs `niri validate`).
  wayland.windowManager.niri = {
    enable = true;
    systemd.enable = false;
    portalPackage = null;

    # Dux Shell writes these into ~/.config/niri/dms/. Included after `settings`
    # so Dux wins. layout.kdl = Settings > System & integrations > niri (gaps,
    # borders, corner radius); it replaces that page's "add include" button,
    # which can't edit the read-only config.kdl. input/binds/outputs/cursor
    # stay skipped (managed here).
    extraConfig = ''
      include optional=true "dms/layout.kdl"
      include optional=true "dms/colors.kdl"
      include optional=true "dms/alttab.kdl"
      include optional=true "dms/windowrules.kdl"
      include optional=true "dms/wpblur.kdl"
    '';

    # settings -> KDL conventions (home-manager's toKDL):
    #   {}        -> flag node (no arguments)
    #   _props    -> key=value properties on the node
    #   _args     -> positional arguments on a parameterized node
    #   _children -> ordered list, needed for repeated node names
    settings = {
      prefer-no-csd = { };

      hotkey-overlay.skip-at-startup = { };

      output = {
        _args = [ "DP-1" ];
        mode = "1920x1080@99.999";
      };

      # blur = {
      #   passes = 2;
      #   offset = 3.0;
      #   noise = 0.03;
      #   saturation = 1.0;
      # };

      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          tap = { };
          natural-scroll = { };
        };
      };

      layout = {
        gaps = 12;
        default-column-width.proportion = 0.5;
        preset-column-widths._children = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        focus-ring.width = 2;
      };

      # Lets shell notification actions focus windows
      debug.honor-xdg-activation-with-invalid-serial = { };

      binds = {
        # Dux Shell (dms ipc)
        "Mod+Space".spawn-sh = "dms ipc call spotlight toggle";
        "Mod+S".spawn-sh = "dms ipc call control-center toggle";
        "Mod+Comma".spawn-sh = "dms ipc call settings focusOrToggle";
        "Mod+Ctrl+N".spawn-sh = "dms ipc call notifications toggle";
        "Mod+Alt+L".spawn-sh = "dms ipc call lock lock";
        "Mod+Shift+Slash".spawn-sh = "dms ipc call keybinds toggle niri";
        "XF86AudioRaiseVolume".spawn-sh = "dms ipc call audio increment 3";
        "XF86AudioLowerVolume".spawn-sh = "dms ipc call audio decrement 3";
        "XF86AudioMute".spawn-sh = "dms ipc call audio mute";
        "XF86MonBrightnessUp".spawn-sh = "dms ipc call brightness increment 5 \"\"";
        "XF86MonBrightnessDown".spawn-sh = "dms ipc call brightness decrement 5 \"\"";

        # Apps
        "Mod+Return".spawn = "kitty";
        "Mod+B".spawn = "firefox";
        "Mod+E".spawn = [
          "dfiles"
          "open"
        ];

        # Windows
        "Mod+Q".close-window = { };
        "Mod+F".maximize-column = { };
        "Mod+Shift+F".fullscreen-window = { };
        "Mod+V".toggle-window-floating = { };
        "Mod+R".switch-preset-column-width = { };
        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";

        # Focus / move
        "Mod+H".focus-column-left = { };
        "Mod+L".focus-column-right = { };
        "Mod+J".focus-window-down = { };
        "Mod+K".focus-window-up = { };
        "Mod+Ctrl+H".move-column-left = { };
        "Mod+Ctrl+L".move-column-right = { };
        "Mod+Ctrl+J".move-window-down = { };
        "Mod+Ctrl+K".move-window-up = { };

        # Workspaces
        "Mod+O".toggle-overview = { };
        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+Shift+1".move-column-to-workspace = 1;
        "Mod+Shift+2".move-column-to-workspace = 2;
        "Mod+Shift+3".move-column-to-workspace = 3;
        "Mod+Shift+4".move-column-to-workspace = 4;
        "Mod+Shift+5".move-column-to-workspace = 5;

        # Screenshots
        "Print".screenshot = { };
        "Mod+Shift+S".screenshot = { };
        "Ctrl+Print".screenshot-screen = { };
        "Alt+Print".screenshot-window = { };

        "Mod+Shift+E".quit = { };
      };

      # Window rules repeat the same node name, so they go in _children.
      _children = [
        # Rounded corners everywhere
        {
          window-rule = {
            geometry-corner-radius = 20;
            clip-to-geometry = true;
          };
        }
        # Allow Niri to blur behind transparent Kitty windows
        # {
        #   window-rule = {
        #     match._props.app-id = "^kitty$";
        #     background-effect = {
        #       blur = true;
        #       xray = false;
        #     };
        #   };
        # }
      ];
    };
  };
}
