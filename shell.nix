let
  pkgs = import <nixpkgs> {};

  # We're using a custom variant of `asciidoctor` that supports rendering Graphviz graphs.
  # Huge thanks to https://zipproth.de/cheat-sheets/hugo-asciidoctor/.
  asciidoctor = pkgs.writeShellScriptBin "asciidoctor" ''
    asciidoctor="${pkgs.asciidoctor}/bin/asciidoctor"
    find="${pkgs.findutils}/bin/find"

    $asciidoctor \
        -s \
        --failure-level=WARN \
        -r asciidoctor-diagram \
        -a source-highlighter=pygments \
        -

    code=$?

    # Since I'm using `opts=inline`, I don't need no diagram artifacts
    if [[ -n $($find . -maxdepth 1 -name 'diag-*') ]]; then
        rm diag-*
    fi

    exit $code
  '';

in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      asciidoctor
      graphviz
      (python2.withPackages (ps: with ps; [ pygments ]))
      sass
    ];
  }
