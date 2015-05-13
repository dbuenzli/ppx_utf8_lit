#!/usr/bin/env ocaml
#directory "pkg";;
#use "topkg.ml";;

let () =
  Pkg.describe "ppx_utf8_lit" ~builder:`OCamlbuild [
    Pkg.lib "pkg/META";
    Pkg.libexec ~auto:true "src/ppx_utf8_lit";
    Pkg.doc "README.md";
    Pkg.doc "CHANGES.md"; ]
