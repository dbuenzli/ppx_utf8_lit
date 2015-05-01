#!/usr/bin/env ocaml
#directory "pkg";;
#use "topkg.ml";;

let () =
  Pkg.describe "ppx_utf8_lit" ~builder:`OCamlbuild [
    Pkg.lib "pkg/META";
    Pkg.bin ~auto:true "src/ppx_utf8_lit"
      ~dst:"../lib/ppx_utf8_lit/ppx_utf8_lit";
    Pkg.doc "README.md";
    Pkg.doc "CHANGES.md"; ]
