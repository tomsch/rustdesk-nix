{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  gtk3,
  gdk-pixbuf,
  pango,
  cairo,
  atk,
  glib,
  wayland,
  libxkbcommon,
  xdotool,
  libappindicator-gtk3,
  libepoxy,
  libxdamage,
  libxcomposite,
  libpulseaudio,
  alsa-lib,
  libva,
  libGL,
  libX11,
  libXrandr,
  libXcursor,
  libXi,
  libXext,
  libXfixes,
  libXtst,
  gst_all_1,
  pam,
}:

stdenv.mkDerivation rec {
  pname = "rustdesk";
  version = "1.4.9";

  src = fetchurl {
    url = "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.deb";
    hash = "sha256-ckS6R8QOgEFyBEv75llGfFTORlVMmOeMjAQG8dYS/aM=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
    pango
    cairo
    atk
    glib
    wayland
    libxkbcommon
    xdotool
    libappindicator-gtk3
    libepoxy
    libxdamage
    libxcomposite
    libpulseaudio
    alsa-lib
    libva
    libGL
    libX11
    libXrandr
    libXcursor
    libXi
    libXext
    libXfixes
    libXtst
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    pam
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share

    # Main application
    cp -r usr/share/rustdesk $out/share/
    cp -r usr/share/icons $out/share/
    cp -r usr/share/applications $out/share/

    # Wrapper mit korrektem Library-Pfad
    makeWrapper $out/share/rustdesk/rustdesk $out/bin/rustdesk \
      --prefix LD_LIBRARY_PATH : "$out/share/rustdesk/lib" \
      --set GDK_BACKEND x11

    # Desktop-Datei anpassen
    substituteInPlace $out/share/applications/rustdesk.desktop \
      --replace-fail "Exec=rustdesk" "Exec=$out/bin/rustdesk"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/rustdesk --version | grep -Fx "${version}"

    runHook postInstallCheck
  '';

  meta = {
    description = "Open-source remote desktop client (TeamViewer alternative)";
    homepage = "https://rustdesk.com";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "rustdesk";
  };
}
