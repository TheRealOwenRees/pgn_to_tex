# Pgn to Tex

## Install

- Install the Opam package with:
  `opam install pgn_to_tex`
- Reference `pgn_to_tex` in the libraries stanza in the relevant dune file

## Usage

```ocaml
open Pgn_logic

let diagrams_json_stringified = {| [{"ply":1,"fen":"rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1"},{"ply":2,"fen":"rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 2"}] |}
let diagram_data = Pgn2tex.parse_diagrams_json diagrams_json_stringified

let game_tex = Pgn2tex.to_tex pgn ~diagram_data ~clock:false
```

This will return a LaTex markdown representation of the PGN file along with chess board diagrams at the specified ply. Clock times can be rendered for both sides if you pass `~clock:true` to the `to_tex` function.

Latex preample and document setup markdown is not included in the output. You will need to add something similar to below around the `game_tex` output to create a valid document:

```
\begin{document}
\begin{multicols}{2}
game_tex goes here
\end{multicols}
\end{document}
```

## Compile a JavaScript version of the library

With the library installed, you can compile the code to JavaScript by running:

```
make build
```

This will generate the JavaScript file at `_build/default/bin/main.bc.js`

This JavaScript file is minified and in CJS format, working in both Node and in the browser.

A single function `to_tex` is exposed, accepting the same arguments as the main library.

## Dependencies

- dune
- sedlex
- menhir
- yojson
- js_of_ocaml-compiler
- ocamlformat
- ocaml-lsp-server
- ounit2
