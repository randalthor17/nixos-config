{ ... }:

{
  users.users."rand" = {
    isNormalUser = true;
    description = "S. M. A Kahar Auhon";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "storage"
      "i2c"
    ];
  };
}
