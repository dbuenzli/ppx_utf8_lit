(*---------------------------------------------------------------------------
   Copyright (c) 2015 Daniel C. Bünzli. All rights reserved.
   Distributed under the BSD3 license, see license at the end of the file.
   %%NAME%% release %%VERSION%%
  ---------------------------------------------------------------------------*)

open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

(* Errors *)

let strf = Printf.sprintf
let err_utf8 ~loc bytes =
  let err = strf "illegal bytes (%S) found in UTF-8 encoded string" bytes in
  raise (Location.Error (Location.error ~loc err))

(* UTF-8 validity check and normalization *)

let utf8_normalize ~loc nf s =
  let b = Buffer.create (String.length s * 3) in
  let n = Uunf.create nf in
  let rec add v = match Uunf.add n v with
  | `Uchar u -> Uutf.Buffer.add_utf_8 b u; add `Await
  | `Await | `End -> ()
  in
  let add_uchar _ _ = function
  | `Malformed bytes -> err_utf8 ~loc bytes
  | `Uchar _ as u -> add u
  in
  Uutf.String.fold_utf_8 add_uchar () s; add `End; Buffer.contents b

(* AST mapper *)

let uattr_to_nf = function
| "u" | "u.nfc" -> `NFC
| "u.nfd" -> `NFD
| "u.nfkd" -> `NFKD
| "u.nfkc" -> `NFKC
| _ -> assert false

let find_uattr attrs =
  let attrs = List.rev attrs (* last u[.*] attribute takes over *) in
  let rec loop = function
  | ({ txt = ("u"|"u.nfd"|"u.nfc"|"u.nfkd"|"u.nfkc" as a); _}, _) :: _ -> Some a
  | _ :: atts -> loop atts
  | [] -> None
  in
  loop attrs

let expr m = function
| { pexp_loc = loc;
    pexp_desc = Pexp_constant (Const_string (str, None));
    pexp_attributes; } as e ->
    begin match find_uattr pexp_attributes with
    | None -> default_mapper.expr m e
    | Some uattr ->
        let ustr = utf8_normalize ~loc (uattr_to_nf uattr) str in
        let pexp_desc = Pexp_constant (Const_string (ustr, None)) in
        default_mapper.expr m { e with pexp_desc }
    end
| e -> default_mapper.expr m e

let pat m = function
| { ppat_loc = loc;
    ppat_desc = Ppat_constant (Const_string (str, None));
    ppat_attributes; } as p ->
    begin match find_uattr ppat_attributes with
    | None -> default_mapper.pat m p
    | Some uattr ->
        let ustr = utf8_normalize ~loc (uattr_to_nf uattr) str in
        let ppat_desc = Ppat_constant (Const_string (ustr, None)) in
        default_mapper.pat m { p with ppat_desc }
    end
| p -> default_mapper.pat m p

let utf8_lit_mapper argv = { default_mapper with expr; pat }

let () = register "utf8_lit" utf8_lit_mapper

(*---------------------------------------------------------------------------
   Copyright (c) 2015 Daniel C. Bünzli.
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   1. Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

   3. Neither the name of Daniel C. Bünzli nor the names of
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  ---------------------------------------------------------------------------*)
