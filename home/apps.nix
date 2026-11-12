{ config, pkgs, ... }:

let
  # KDE Connect's "Browse" goes through KIO (kdeconnect://), which Dux Files
  # can't use. The sshfs mount itself is fine, so link each paired device's
  # storage as ~/Devices/<name>. Built from kdeconnect's trusted_devices, so no
  # hardcoded IDs. Links dangle while a device is disconnected / not mounted.
  trusted = "${config.xdg.configHome}/kdeconnect/trusted_devices";
  kdeconnectLinks = pkgs.writeShellApplication {
    name = "kdeconnect-links";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gawk
    ];
    text = ''
      dir="$HOME/Devices"
      mkdir -p "$dir"
      find "$dir" -maxdepth 1 -type l -delete
      [ -r "${trusted}" ] || exit 0
      # [<id>] sections with name=<device name>
      awk -F= '/^\[.*\]$/ { id = substr($0, 2, length($0) - 2) }
               $1 == "name" && id != "" { print id "\t" substr($0, 6) }' "${trusted}" |
        while IFS=$'\t' read -r id name; do
          name=''${name//\//_}
          ln -sfn "$XDG_RUNTIME_DIR/$id/storage/emulated/0" "$dir/$name"
        done
    '';
  };
in
{
  systemd.user.services.kdeconnect-links = {
    Unit.Description = "Link KDE Connect device storage into ~/Devices";
    Service = {
      Type = "oneshot";
      ExecStart = "${kdeconnectLinks}/bin/kdeconnect-links";
    };
    Install.WantedBy = [ "default.target" ];
  };
  # Re-run when a device is paired/unpaired/renamed.
  systemd.user.paths.kdeconnect-links = {
    Unit.Description = "Watch KDE Connect paired devices";
    Path.PathChanged = trusted;
    Install.WantedBy = [ "default.target" ];
  };

  programs.kitty = {
    enable = true;
    settings = {
      hide_window_decorations = "yes";
    };
    # Dux Shell writes dank-theme.conf and dank-tabs.conf here.
    extraConfig = "globinclude dank-*.conf";
  };

  programs.firefox = {
    enable = true;
    # Pywalfox: native host + extension (Dux Shell themes Firefox through it).
    nativeMessagingHosts = [ pkgs.pywalfox-native ];
    policies.ExtensionSettings."pywalfox@frewacom.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/pywalfox/latest.xpi";
      installation_mode = "normal_installed";
    };
  };
  programs.chromium.enable = true;

  programs.zathura.enable = true; # PDFs
  programs.mpv.enable = true;
  programs.yt-dlp.enable = true;

  home.packages = with pkgs; [
    # Dux Shell calls `pywalfox` from PATH to theme Firefox
    pywalfox-native

    # Files / viewers / media
    loupe # images
    pavucontrol
  ];
}
