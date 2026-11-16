# Khipro Dark, a compositional Bengali input method, as m17n files (.mim + icon).
# MIT, https://github.com/KhiproTeam/khipro-dark-m17n. Linked into ~/.m17n.d by
# home/input.nix, where m17n (and so fcitx5-m17n) finds it.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "khipro-dark-m17n";
  version = "0-unstable-2026-11-16";

  src = fetchFromGitHub {
    owner = "KhiproTeam";
    repo = "khipro-dark-m17n";
    rev = "9c1b040e13bc6bca1d4a34038596c704f45c2ed1";
    hash = "sha256-WCZ9vvKUl8Aw2XuGbGaCru16ine4aXn1a2a+GiQ+KAM=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 bn-khipro-dark.mim $out/share/m17n/bn-khipro-dark.mim
    install -Dm644 bn-khipro-dark.png $out/share/m17n/icons/bn-khipro-dark.png
    runHook postInstall
  '';

  meta = {
    description = "Khipro Dark, a compositional Bengali input method, for m17n";
    homepage = "https://github.com/KhiproTeam/khipro-dark-m17n";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
