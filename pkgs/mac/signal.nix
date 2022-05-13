{ pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation rec {
  pname = "signal";
  version = "5.43.0";
  sha = "sha256-E43X8wO/uLrBtYPaAT+RdVCub3rKEd4SkhRMqtZekZo=";

  buildInputs = [ pkgs.undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out/Applications
    cp -r Signal.app $out/Applications/Signal.app
  '';

  src = pkgs.fetchurl {
    name = "signal-${version}.dmg";
    url = "https://updates.signal.org/desktop/signal-desktop-mac-universal-${version}.dmg";    
    sha256 = sha;
  };

  meta = with pkgs.lib; {
    description = "Signal messenger";
    homepage = "https://signal.org";
    maintainers = [];
    platforms = platforms.darwin;
  };
}
