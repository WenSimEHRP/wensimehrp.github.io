{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

mkShell rec {
  nativeBuildInputs = [
    bun
    typst
  ];
}
