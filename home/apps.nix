{ pkgs, ... }:

{
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
