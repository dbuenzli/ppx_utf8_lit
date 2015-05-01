open Ocamlbuild_plugin

let () =
  dispatch begin function
  | After_rules ->
    flag ["ocaml"; "compile"; "ppx_utf8_lit"] &
    S [A "-ppx"; A "src/ppx_utf8_lit.native"];
  | _ -> ()
  end
