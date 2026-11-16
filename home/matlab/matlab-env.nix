{
  pkgs ? import <nixpkgs> { },
  version ? "2025b",
  # Where MATLAB is installed (only used for the menu icon; the launcher itself
  # resolves the root at run time from ~/.matlab/R<ver>/.matlabfolder or MATLAB_ROOT).
  matlabRoot ? "${builtins.getEnv "HOME"}/matlab/${version}",
}:

# Launcher for an installed MATLAB on a non-FHS system: `matlab` and `mex`
# commands plus a menu entry, each running MATLAB inside an FHS sandbox.
# MATLAB itself is installed separately (see ~/matlab/installer-env.nix + setup.sh).

let
  common = import ./fhs-common.nix pkgs;

  launcher =
    tool:
    pkgs.writeShellScript "matlab-${tool}" ''
      root="''${MATLAB_ROOT:-}"
      if [ -z "$root" ] && [ -f "$HOME/.matlab/R${version}/.matlabfolder" ]; then
        root=$(<"$HOME/.matlab/R${version}/.matlabfolder")
      fi
      root="''${root:-$HOME/matlab/${version}}"
      if [ ! -x "$root/bin/${tool}" ]; then
        echo "MATLAB not found at $root (set MATLAB_ROOT)" >&2
        exit 1
      fi
      exec "$root/bin/${tool}" "$@"
    '';

  mkEnv =
    tool:
    pkgs.buildFHSEnv {
      name = tool;
      inherit (common) targetPkgs;
      # Java UI (MATLAB desktop) misbehaves under non-reparenting WMs / XWayland (niri).
      profile = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      runScript = launcher tool;
    };

  desktopItem = pkgs.makeDesktopItem {
    name = "matlab-${version}";
    desktopName = "MATLAB ${version}";
    comment = "Language of Technical Computing";
    categories = [
      "Science"
      "Math"
      "Development"
    ];
    exec = "matlab -desktop";
    icon = "${matlabRoot}/bin/glnxa64/cef_resources/matlab_icon.png";
    terminal = false;
  };
in
pkgs.symlinkJoin {
  name = "matlab-${version}-launcher";
  paths = [
    (mkEnv "matlab")
    (mkEnv "mex")
    desktopItem
  ];
}
