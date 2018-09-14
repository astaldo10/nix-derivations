#{ stdenv, lib, fetchFromGitHub, buildFHSUserEnv, writeScript, makeDesktopItem, qmake }:
with import <nixpkgs> { };

let platforms = [ "i686-linux" "x86_64-linux" ]; in

assert lib.elem stdenv.system platforms;

# MEGASync client to bootstrap installation.
# The client is self-updating, so the actual version may be newer.
# let
#   installer = "https://github.com/meganz/MEGAsync/archive/${version}_Linux.tar.gz";
# in

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

  # Get sha256 using $> nix-prefetch-url --unpack https://github.com/meganz/megasync/archive/v3.6.6.0_Linux.tar.gz
  src = fetchFromGitHub {
    owner = "meganz";
    repo = "MEGAsync";
    rev = "v${version}_Linux";
    sha256 = "12lg3h62wdfms15shc9djjzx27svnqr9aib9ssdggwp00rydmaqs";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ qmake ];
  buildInputs = [ libtool unzip autoconf wget automake qt4 pkgconfig ];

  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    cp "${desktopItem}/share/applications/"* $out/share/applications
  '';

  preConfigure = ''
    patchShebangs ./src/configure
    patchShebangs ./src/MEGASync/mega/contrib/build_sdk.sh
  '';

  buildPhase = ''
    cd ./src
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
