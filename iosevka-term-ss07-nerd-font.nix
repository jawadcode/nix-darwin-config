{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation {
  pname = "iosevka-term-ss07-nerd-font";
  version = "33.1.0";
  src = fetchzip {
    url = "https://github.com/jawadcode/IosevkaTermSS07-Nerd-Font/archive/refs/tags/v33.1.0.zip";
    hash = "sha256-mWXj/tZJNmMQCfoc0HDpl70kDjNx/42vJTg8Pb1/enI=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype
    cp patched/IosevkaTermSS07NerdFont-*.ttf $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://typeof.net/Iosevka/";
    description = "Versatile typeface for code, from code.";
    license = licenses.ofl;
    platform = platforms.all;
    maintainers = [];
  };
}
