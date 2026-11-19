{ pkgs, ... }:

let
  vestaRepo = pkgs.callPackage ../../pkgs/vesta-flatpak/repo.nix { };
in
{
  networking.networkmanager.enable = true;

  # NetworkManager "shared" connections (hotspot / internet sharing) run their own dnsmasq, but the NixOS firewall drops
  # DHCP and DNS from the clients. Fedora's firewalld has an "nm-shared" zone for this; here a dispatcher script opens
  # UDP 67/53 and TCP 53 on the interface only while a shared connection is up on it. A firewall reload drops the rules
  # until the connection is brought up again.
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "nm-shared-firewall" ''
        iface="$1"; action="$2"
        [ "$action" = up ] || [ "$action" = down ] || exit 0
        method=$(${pkgs.networkmanager}/bin/nmcli -g ipv4.method connection show uuid "$CONNECTION_UUID" 2>/dev/null)
        [ "$method" = shared ] || exit 0
        ipt=${pkgs.iptables}/bin/iptables
        for rule in "udp --dport 67" "udp --dport 53" "tcp --dport 53"; do
          if [ "$action" = up ]; then
            $ipt -C nixos-fw -i "$iface" -p $rule -j ACCEPT 2>/dev/null || $ipt -I nixos-fw 1 -i "$iface" -p $rule -j ACCEPT
          else
            $ipt -D nixos-fw -i "$iface" -p $rule -j ACCEPT 2>/dev/null || true
          fi
        done
      '';
    }
  ];

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

      # VESTA crystal viewer, from the local repo built out of
      # pkgs/vesta-flatpak/*.yml. (A .flatpak bundle can't be used: bundles
      # drop the extra-data info.) The repo only holds a wrapper; VESTA itself
      # is downloaded from jp-minerals.org on install (hash-pinned in the
      # manifest) and must not be committed here, the repo is public.
      # To update: rebuild with flatpak-builder --repo=pkgs/vesta-flatpak/repo.
      {
        appId = "org.jp_minerals.VESTA";
        origin = "vesta-local";
      }
    ];
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "vesta-local";
        location = "file://${vestaRepo}";
        args = "--no-gpg-verify";
      }
    ];

    # Theming for flatpak apps: home/theming.nix (user-level global override).
  };

  # Keep exactly one VESTA remote (vesta-local), on every activation:
  # - installing a .flatpak bundle (even by hand) creates a hidden
  #   vesta<N>-origin remote each time, and they pile up. Delete them.
  # - nix-flatpak only adds a remote if the name is missing, so after the repo
  #   is rebuilt (new store path) vesta-local would keep the stale URL. Re-point it.
  systemd.services.flatpak-managed-install = {
    path = [
      pkgs.flatpak
      pkgs.gnugrep
      pkgs.gnused
    ];
    preStart = ''
      for n in $(grep -oE '^\[remote "vesta[0-9]*-origin"\]' /var/lib/flatpak/repo/config 2>/dev/null | sed -E 's/.*"(.*)".*/\1/'); do
        flatpak remote-delete --system --force "$n" || true
      done
      if grep -q '^\[remote "vesta-local"\]' /var/lib/flatpak/repo/config 2>/dev/null; then
        flatpak remote-modify --system --url=file://${vestaRepo} vesta-local || true
      fi
    '';
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
