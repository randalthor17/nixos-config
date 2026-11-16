{ pkgs, config, ... }:

{
  # MATLAB launcher (`matlab`, `mex`, menu entry) for an install made with
  # ~/matlab/setup.sh. Imported only when ./matlab/matlab-env.nix exists
  # (see home/default.nix); the launcher reports a clear error if MATLAB
  # itself isn't installed.
  home.packages = [
    (import ./matlab/matlab-env.nix {
      inherit pkgs;
      matlabRoot = "${config.home.homeDirectory}/matlab/2025b";
    })
  ];
}
