{ ... }:

{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelParams = [
      "quiet"
      "splash"
      "console=/dev/null"
    ];
    kernelModules = [ "i2c-dev" ];
  };
}
