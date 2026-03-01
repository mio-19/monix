{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  glib,
  libglibutil,
  asteroidosMetaAsteroid,
}:

stdenv.mkDerivation rec {
  pname = "libncicore";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "mer-hybris";
    repo = "libncicore";
    rev = "7c4e1a8a743bbd713e684a824442f663cadb7a83";
    hash = "sha256-T2S/UqYwGztXYKuz0b8biwEnrLKXvWxF1YnOZD5bHZY=";
  };

  patches = [
    "${asteroidosMetaAsteroid}/recipes-nemomobile/libnci/libncicore/0001-Makefile-Allow-for-CC-to-be-overridden.patch"
  ];

  postPatch = ''
    # Use stdenv-provided cross-aware pkg-config wrapper.
    substituteInPlace Makefile unit/common/Makefile \
      --replace-fail "pkg-config" "$PKG_CONFIG"
  '';

  nativeBuildInputs = [
    buildPackages.pkg-config
  ];

  buildInputs = [
    glib
    libglibutil
  ];

  makeFlags = [
    "KEEP_SYMBOLS=1"
    "LIBDIR=lib"
    "PKG_CONFIG=${buildPackages.pkg-config}/bin/pkg-config"
  ];

  buildPhase = ''
    runHook preBuild
    make $makeFlags release pkgconfig
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make $makeFlags install install-dev DESTDIR=$out
    runHook postInstall
  '';

  meta = with lib; {
    description = "mer-hybris libncicore";
    homepage = "https://github.com/mer-hybris/libncicore";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
