#{ stdenv, lib, buildFHSUserEnv, writeScript, makeDesktopItem }:
with import <nixpkgs> {};

let platforms = [ "i686-linux" "x86_64-linux" ]; in

assert lib.elem stdenv.system platforms;

# MEGASync client to bootstrap installation.
# The client is self-updating, so the actual version may be newer.
let
  installer = "https://github.com/meganz/MEGAsync/archive/${version}_Linux.tar.gz";
in

let
  desktopItem = makeDesktopItem {
    name = "megasync";
    exec = "megasync";
    comment = "Sync your files across computers and to the web";
    desktopName = "MEGASync";
    genericName = "File Synchronizer";
    categories = "Network;FileTransfer;";
    startupNotify = "false";
  };
in

stdenv.mkDerivation rec {

  name = "megasync-${version}";
  version = "3.6.6.0";

  # Fetching from GitHub instead of taking an "official" source
  # tarball because of missing submodules there
  src = fetchFromGitHub {
    owner = "meganz";
    repo = "MEGAsync";
    rev = "v${version}_Linux";
    sha256 = "1jivph7lppnflmjsiirhgv0mnh8mxx41i1vzkk78ynn00rzacx3j";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
  #  cmake
  #  makeWrapper
  ];

  buildInputs = [
  #  python
  #  python.pkgs.numpy
  #  libGLU_combined
  #  libXt
  #  qtbase
  #  qtx11extras
  #  qttools
  #  qtxmlpatterns
  ];

  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    cp "${desktopItem}/share/applications/"* $out/share/applications
  '';
  
  buildPhase = ''
    cd src
    ./configure
    qmake MEGA.pro
    lrelease MEGASync/MEGASync.pro
    make
  '';

  meta = with lib; {
    description = "Online stored folders (daemon version)";
    homepage    = https://mega.nz/;
    license     = licenses.free;
    #maintainers = with maintainers; [ ttuegel ];
    platforms   = [ "i686-linux" "x86_64-linux" ];
  };
}
