(*---------------------------------------------------------------------------
   Copyright (c) 2015 Daniel C. Bünzli. All rights reserved.
   Distributed under the BSD3 license, see license at the end of the file.
   %%NAME%% release %%VERSION%%
  ---------------------------------------------------------------------------*)

let assert_lits () =
  assert ("Révolte"[@u] = "R\xC3\xA9volte");
  assert ("Révolte"[@u.nfc] = "R\xC3\xA9volte");
  assert ("Révolte"[@u.nfd] = "Re\xCC\x81volte");
  assert ("ﬁ"[@u.nfd] = "\xEF\xAC\x81");
  assert ("ﬁ"[@u.nfc] = "\xEF\xAC\x81");
  assert ("ﬁ"[@u.nfkd] = "fi");
  assert ("ﬁ"[@u.nfkc] = "fi");
  ()

let assert_pats () =
  assert (match "Révolte"[@u] with "Révolte"[@u] -> true | _ -> false);
  assert (match "Révolte"[@u.nfc] with "Révolte"[@u.nfc] -> true  | _ -> false);
  assert (match "Révolte"[@u.nfc] with "Révolte"[@u.nfd] -> false | _ -> true);
  assert (match "Révolte"[@u.nfd] with "Révolte"[@u.nfd] -> true  | _ -> false);
  assert (match "Révolte"[@u.nfd] with "Révolte"[@u.nfc] -> false | _ -> true);
  assert (match "ﬁ"[@u.nfc] with "ﬁ"[@u.nfc]  -> true  | _ -> false );
  assert (match "ﬁ"[@u.nfc] with "ﬁ"[@u.nfd]  -> true  | _ -> false );
  assert (match "ﬁ"[@u.nfc] with "ﬁ"[@u.nfkd] -> false | _ -> true );
  assert (match "ﬁ"[@u.nfc] with "ﬁ"[@u.nfkc] -> false | _ -> true );
  assert (match "ﬁ"[@u.nfd] with "ﬁ"[@u.nfd]  -> true  | _ -> false );
  assert (match "ﬁ"[@u.nfkd] with "fi"        -> true  | _ -> false );
  assert (match "ﬁ"[@u.nfkc] with "fi"        -> true  | _ -> false );
  ()

let () =
  assert_lits ();
  assert_pats ();
  ()

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
