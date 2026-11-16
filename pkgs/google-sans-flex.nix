{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "google-sans-flex";
  version = "5.000";

  src = fetchzip {
    url = "https://github.com/googlefonts/googlesans-flex/releases/download/v${version}/GoogleSansFlex-v${version}.zip";
    hash = "sha256-NkCK4oZtmkuVuMFnZiVMeJyG0zuy9Ew0sxUQXzA4oKY=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t "$out/share/fonts/truetype" *.ttf
    runHook postInstall
  '';

  meta = with lib; {
    description = "Google Sans Flex variable font";
    homepage = "https://github.com/googlefonts/googlesans-flex";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
