{ pkgs, ... }:

{
  networking.networkmanager.enable = true;

  services.flatpak = {
    enable = true;
    packages = [
      "org.qbittorrent.qBittorrent"

      # ATK/VXE mouse configurator, only shipped as a release bundle
      # (https://github.com/NasirA1991/atk-control). hidraw access comes from
      # the udev rules in hosts/nixos/default.nix. Bump url + sha256 to update
      # (sha256 is in the release's SHA256SUMS).
      rec {
        appId = "io.github.atkcontrol.AtkControl";
        sha256 = "74843a3f775ad4506d4460f811debdd1be1ce612cca8b514fd694e390a528656";
        bundle = "${pkgs.fetchurl {
          url = "https://github.com/NasirA1991/atk-control/releases/download/v0.9.5/atk-control-0.9.5-x86_64.flatpak";
          inherit sha256;
        }}";
      }
    ];

    # Dux theming inside the sandbox (system-wide override for all apps):
    # - GTK4/libadwaita read ~/.config/gtk-4.0/gtk.css (imports Dux's
    #   dank-colors.css); GTK3 reads gtk-3.0 + the adw-gtk3 copy Dux keeps in
    #   ~/.local/share/themes (theme name comes via the settings portal).
    # - Qt: KDE runtimes ship no qt5ct/qt6ct plugin, so the host's
    #   QT_QPA_PLATFORMTHEME=qt5ct does nothing there. Use KDE's own platform
    #   theme, which reads colors from kdeglobals (-> Dux's DankMatugen scheme).
    overrides.settings.global = {
      Context.filesystems = [
        "xdg-config/gtk-3.0:ro"
        "xdg-config/gtk-4.0:ro"
        "xdg-config/kdeglobals:ro"
        "xdg-data/themes:ro"
      ];
      Environment.QT_QPA_PLATFORMTHEME = "kde";
    };
  };

  # winboat runs Windows in a container; it needs a runtime (and KVM).
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true; # compose networks resolve container names
  };
  programs.kdeconnect.enable = true;

  # Mounting drives in file managers
  services.udisks2.enable = true;
  services.gvfs.enable = true;
}
