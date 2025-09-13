{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

mkShell rec {
  nativeBuildInputs = [
    fontconfig
    bun
    typst
    # font section
    merriweather
    merriweather-sans
    sarasa-gothic
  ];
  shellHook = ''
      export FONTCONFIG_FILE=${makeFontsConf {
      fontDirectories = [
        merriweather
        merriweather-sans
        sarasa-gothic
      ];
    }};
  '';
}
