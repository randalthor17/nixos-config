{ pkgs, ... }:

{
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;

  # i2c (+ ddcutil) for monitor brightness over DDC/CI
  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.ddcutil ];

  # Compressed swap in RAM (zstd, up to 50% of RAM by default)
  zramSwap.enable = true;

  # ---- Audio -------------------------------------------------------------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ---- Power -------------------------------------------------------------
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # The USB mouse dongle (wake-enabled) fires a PME wake if suspend starts while
  # input is still settling, so the PC wakes immediately. Delay entering S3
  # briefly; mouse wake itself stays enabled.
  systemd.services.systemd-suspend.serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";

  # services.hardware.openrgb.enable = true;
  # hardware.fancontrol.enable = true; # coolercontrol
}
