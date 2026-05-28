(lang dune 3.21)

(using menhir 3.0)

(name pgn_to_tex)

(generate_opam_files true)

(source
 (github therealowenrees/pgn_to_tex))

(authors "Owen Rees <owenrees.dev@gmail.com>")

(maintainers "Owen Rees <owenrees.dev@gmail.com>")

(license AGPLv3)

(documentation https://github.com/TheRealOwenRees/pgn_to_tex/README.md)

(version 0.0.1)

(package
 (name pgn_to_tex)
 (synopsis "A chess PGN to TeX conversion tool")
 (description
  "Convert PGN files to LaTeX markdown, including rendered images of selected positions")
 (depends
  (ocaml
   (>= 5.4))
  (sedlex
   (>= 3.7))
  (menhir
   (>= 20260209))
  (yojson
   (>= 3.0))
  (ounit2
   (and
    :with-test
    (>= 2.2.7)))
  ("ocamlformat"
   (and :with-dev-setup)))
 (tags
  ("pgn" "latex" "chess" "parser")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
