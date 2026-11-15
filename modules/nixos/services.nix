{ ... }:

{
  networking.networkmanager.enable = true;

  services.flatpak = {
    enable = true;
    packages = [ "org.qbittorrent.qBittorrent" ];
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
