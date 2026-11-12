{
  config,
  osConfig,
  pkgs,
  ...
}:

# KDE Connect mounts each device over sshfs in $XDG_RUNTIME_DIR/<id>, which
# file managers hide, and its "Browse" opens a kdeconnect:// URL through KIO,
# which Dux Files can't read (KIO then hands it an empty "unnamed" file).
#
# - kdeconnect-devices watch: while a paired device is reachable, bind-mount
#   its storage at ~/Devices/<name> (bindfs). gvfs shows user FUSE mounts under
#   $HOME, so it appears as a mounted device in Dux Files / other file managers.
# - kdeconnect-devices open: Dux Files' launcher, overridden below to declare
#   kdeconnect:// support; maps those URLs to the ~/Devices mount (mounting on
#   demand), passes everything else to dfiles unchanged.
let
  dfiles = osConfig.programs.dux-files.package;
  trusted = "${config.xdg.configHome}/kdeconnect/trusted_devices";

  kdeconnectDevices = pkgs.writeShellApplication {
    name = "kdeconnect-devices";
    runtimeInputs = with pkgs; [
      bindfs
      coreutils
      findutils
      gawk
      gnugrep
      systemd # busctl
      util-linux # mountpoint
    ];
    text = ''
      # fusermount3 is setuid, only in /run/wrappers/bin
      export PATH="/run/wrappers/bin:$PATH"
      devdir="$HOME/Devices"

      # "<id>\t<name>" for every paired device
      devices() {
        [ -r "${trusted}" ] || return 0
        awk -F= '/^\[.*\]$/ { id = substr($0, 2, length($0) - 2) }
                 $1 == "name" && id != "" { print id "\t" substr($0, 6) }' "${trusted}"
      }
      name_of() { devices | awk -F'\t' -v id="$1" '$1 == id { print $2; exit }'; }
      target() { printf '%s/%s' "$devdir" "''${1//\//_}"; }

      dev() { busctl --user "$1" org.kde.kdeconnect "/modules/kdeconnect/devices/$2''${3:+/$3}" "''${@:4}" 2>/dev/null; }
      reachable() { [ "$(dev get-property "$1" "" org.kde.kdeconnect.device isReachable)" = "b true" ]; }
      # first (internal) storage dir: a{sv} N "/run/user/.../storage/emulated/0" s "Internal storage"
      storage() { dev call "$1" sftp org.kde.kdeconnect.device.sftp getDirectories | grep -o '"[^"]*"' | head -n1 | tr -d '"'; }

      mount_dev() { # id name
        local dst src
        dst=$(target "$2")
        if mountpoint -q "$dst"; then
          ls "$dst" >/dev/null 2>&1 && return 0
          fusermount3 -uz "$dst" || true # stale
        fi
        dev call "$1" sftp org.kde.kdeconnect.device.sftp mountAndWait >/dev/null || return 1
        src=$(storage "$1")
        [ -n "$src" ] || return 1
        mkdir -p "$dst"
        bindfs --no-allow-other -o fsname=kdeconnect,subtype=kdeconnect "$src" "$dst"
      }

      umount_dev() { # name
        local dst
        dst=$(target "$1")
        if mountpoint -q "$dst"; then fusermount3 -uz "$dst" || true; fi
        [ -d "$dst" ] && rmdir "$dst" 2>/dev/null || true
      }

      umount_all() {
        local _id n
        while IFS=$'\t' read -r _id n; do umount_dev "$n"; done < <(devices)
        exit 0
      }

      watch() {
        mkdir -p "$devdir"
        find "$devdir" -maxdepth 1 -type l -delete # links from the old setup
        trap umount_all TERM INT
        # Mount once per connection (not every tick), so an unmount from the
        # file manager sticks until the device reconnects or Browse is used.
        declare -A up=()
        while :; do
          while IFS=$'\t' read -r id name; do
            if reachable "$id"; then
              if [ -z "''${up[$id]:-}" ] && mount_dev "$id" "$name"; then up[$id]=1; fi
            else
              unset 'up[$id]'
              umount_dev "$name"
            fi
          done < <(devices)
          sleep 5 & wait $!
        done
      }

      open() {
        local a args=() rest id sub name dst root src full
        for a in "$@"; do
          case $a in
            kdeconnect://*)
              rest=''${a#kdeconnect://}
              id=''${rest%%/*}
              sub=''${rest#"$id"}
              name=$(name_of "$id")
              if [ -n "$name" ] && mount_dev "$id" "$name"; then
                dst=$(target "$name")
                # kdeconnect://<id>/<path> is relative to the sshfs root
                root=$(dev call "$id" sftp org.kde.kdeconnect.device.sftp mountPoint | grep -o '"[^"]*"' | tr -d '"')
                src=$(storage "$id")
                full="$root$sub"
                case $full in "$src"/*) dst="$dst''${full#"$src"}" ;; esac
                args+=("$dst")
              fi
              ;;
            *) args+=("$a") ;;
          esac
        done
        exec ${dfiles}/bin/dfiles open "''${args[@]}"
      }

      case ''${1:-} in
        watch) watch ;;
        open) shift; open "$@" ;;
        *) echo "usage: kdeconnect-devices watch | open [--new-window] URL..." >&2; exit 2 ;;
      esac
    '';
  };

  # Same entry, same id (so mimeapps defaults still match), but launched via
  # the wrapper and advertising kdeconnect:// so KIO passes the URL as-is
  # instead of downloading it through kioexec.
  dfilesDesktop = pkgs.runCommand "dev.duxlabs.files.desktop" { } ''
    sed -e 's|${dfiles}/bin/dfiles open|${kdeconnectDevices}/bin/kdeconnect-devices open|' \
        -e '/^Keywords=/a X-KDE-Protocols=file,kdeconnect,sftp,smb,trash' \
        ${dfiles}/share/applications/dev.duxlabs.files.desktop > $out
  '';
in
{
  home.packages = [ kdeconnectDevices ];

  xdg.dataFile."applications/dev.duxlabs.files.desktop".source = dfilesDesktop;

  systemd.user.services.kdeconnect-devices = {
    Unit = {
      Description = "Mount reachable KDE Connect devices in ~/Devices";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${kdeconnectDevices}/bin/kdeconnect-devices watch";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
