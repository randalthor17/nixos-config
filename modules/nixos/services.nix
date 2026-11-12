{ ... }:

{
  networking.networkmanager.enable = true;

  services.flatpak.enable = true;
  programs.kdeconnect.enable = true;

  # Mounting drives in file managers
  services.udisks2.enable = true;
  services.gvfs.enable = true;
}
