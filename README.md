ppx_utf8_lit — UTF-8 string literals and patterns for OCaml
------------------------------------------------------------
Experiment

This ppx explores *one* design direction to improve the Unicode
support provided by the OCaml compiler. See the
[rationale](#Rationale).

`ppx_utf8_lit` depends on [Uutf][1] and [Uunf][2]

[1]: http://erratique.ch/software/uutf
[2]: http://erratique.ch/software/uunf

# Installation and usage

Note, `ppx_utf8_lit` is not formally released, it is an experiment.

```
# With opam 1.2 or later
opam pin add uunf http://erratique.ch/repos/uunf.git
opam pin add ppx_utf8_lit http://erratique.ch/repos/ppx_utf8_lit.git
```

The `ppx` understands the following attributes on string literals
and patterns:

* `"Révolte"[@u]` checks for UTF-8 validity and puts the string in NFC.
* `"Révolte"[@u.nfc]` checks for UTF-8 validity and puts the string in NFC.
* `"Révolte"[@u.nfd]` checks for UTF-8 validity and puts the string in NFD.
* `"Révolte"[@u.nfkd]` checks for UTF-8 validity and puts the string in NFKD.
* `"Révolte"[@u.nfkc]` checks for UTF-8 validity and puts the string in NFKC.

To compile a source with the `ppx`:

```
ocamfind ocamlc -package ppx_utf8_lit src.ml
```

# Rationale

Rather than introducing a new Unicode string datastructure and
associated new literal and pattern notations `ppx_utf8_lit` tries to
improve the situation for libraries and programs that adopted the idea
of interpreting current OCaml strings (which are fundamentally
sequences of bytes) as UTF-8 encoded text. It does so by using the
attribute mechanism introduced in OCaml 4.02.

The advantage of interpreting current OCaml strings as UTF-8 encoded
text are:

1. No new notation or primitive type is introduced. This means that
the surface syntax of the language doesn't change and that other
subsystems remain untouched (e.g. format specifiers). Besides nothing
needs to change in the compiler itself except at the parsing phase.

2. It plays exceptionally well with the current OCaml system as it
exists (for example with `Printf`, `Format` and IO primitives).

3. Since `latin1` identifiers in source code have been deprecated in
OCaml 4.01, if a source is only using `US-ASCII` identifiers it can be
UTF-8 encoded which allows to directly write UTF-8 string literals and
patterns.

However there are two problems with these UTF-8 literals and patterns:

1. The compiler sees them as sequences of bytes, hence they cannot be
   trusted as being valid UTF-8 in your program (e.g. if your editor
   has bugs in its UTF-8 encoder). The only way to make sure the
   encoding will be correct is to escape the UTF-8 encoding which is
   not particularly readable (e.g. `"R\xC3\xA9volte"` vs `"Révolte"`) .

2. You don't get any guarantee on the Unicode normal form (if any) in
   which the literals and patterns occur. They are subject to what
   your editor decided to choose. Which is problematic for testing
   equality (see
   [here](http://erratique.ch/software/uucp/doc/Uucp#equivalence) for
   a quick recall on why Unicode normalization is essential for
   testing equality). This means that you have to convert to a normal
   form manually and explicitely escape the UTF-8 which is neither
   convenient nor readable.  (e.g. `"Révolte"` in NFD would be
   `"Re\xCC\x81volte"`)

In order to aleviate this, we introduce 5 annotations on string
literals and patterns. Any string sporting such an annotation will be
checked for UTF-8 validity with compilation failing if that is not the
case. Besides each of the annotation will guarantee the string is
converted to one of the four Unicode normal form.

* `"Révolte"[@u]` checks for UTF-8 validity and puts the string in NFC.
* `"Révolte"[@u.nfc]` checks for UTF-8 validity and puts the string in NFC.
* `"Révolte"[@u.nfd]` checks for UTF-8 validity and puts the string in NFD.
* `"Révolte"[@u.nfkd]` checks for UTF-8 validity and puts the string in NFKD.
* `"Révolte"[@u.nfkc]` checks for UTF-8 validity and puts the string in NFKC.

The reason for using NFC for the `[@u]` notation is that this is the
normalization recommended by the w3c for the
[web](http://www.w3.org/TR/charmod-norm/#h4_choice-of-normalization-form). I
have no strong opinion about that though (thought about a filename
friendly normalization form but according to
[this](https://github.com/whitequark/ocaml-m17n#interaction-with-filesystem)
there's no cross-platform consensus – and it some sense it should be
the task of the FS APIs to normalize whatever we feed them with).

This means that now, if I you make sure that the strings you input are
in a given normal form (using
e.g. [Uutf](http://erratique.ch/software/uutf) and
[Uunf](http://erratique.ch/software/uunf)) you can safely pattern
match on them. For example:

```ocaml
let is_fr_revolt s = match s (* assuming [s] is in NFC form *) with
| "Révolte"[@u] -> true
| _ -> false

let () =
  assert (is_fr_revolt ("Révolte"[@u]));
  assert (not (is_fr_revolt ("Révolte"[@u.nfd]));
  ()
```
