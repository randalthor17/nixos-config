# Shared by installer-env.nix and matlab-env.nix: the FHS package set.
pkgs:
let
  # nixpkgs flags gtk2 as broken (EOL) but MATLAB's CEF/window libs still link it.
  gtk2 = pkgs.gtk2.overrideAttrs (o: {
    meta = removeAttrs o.meta [ "problems" ];
  });
  pwdFix = pkgs.runCommand "pwd-fix" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.coreutils}/bin/pwd $out/bin/pwd
  '';
in
{
  targetPkgs =
    pkgs: with pkgs; [
      # shell tooling used by setup.sh
      bash
      coreutils
      util-linux
      gawk
      gnugrep
      gnused
      findutils
      which
      file
      gnutar
      gzip
      bzip2
      xz
      unzip
      libarchive # libarchive provides bsdtar
      xdg-utils
      xdg-user-dirs
      procps
      curl
      cacert

      # runtime libraries for the installer and MATLAB
      glibc
      zlib
      gcc
      stdenv.cc.cc.lib
      libx11
      libxt
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxinerama
      libxkbcommon
      glib
      gtk3
      pango
      cairo
      atk
      gdk-pixbuf
      at-spi2-atk
      at-spi2-core
      nss
      nspr
      dbus
      alsa-lib
      libpulseaudio
      cups
      expat
      libdrm
      libgbm
      libGL
      libGLU
      fontconfig
      freetype
      gnumake
      gfortran
      binutils
      pkg-config # mex (C/C++/Fortran), Coder builds
      pam
      libxcrypt
      libxcrypt-legacy
      ncurses5
      openssl
      libuuid
      libselinux
      libsndfile
      libxft
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      libxml2
      libxslt
      pixman
      harfbuzz
      fribidi
      udev
      krb5
      libxxf86vm
      libsm
      libice
      libxmu
      gtk2
      pwdFix
    ];
}
