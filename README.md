# Pgn to Tex

## Install

- Install the Opam package with:
  `opam install pgn_to_tex`
- Reference `pgn_to_tex` in the libraries stanza in the relevant dune file

## Usage

```ocaml
open Pgn_to_tex

let diagrams_json_stringified =
  {| [
       {"ply":1,"fen":"rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1","path":["d4"]},
       {"ply":2,"fen":"rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 2","path":["d4","d5"]},
       {"ply":4,"fen":"rnbqkbnr/ppp1pppp/3p4/8/3PP3/8/PPP2PPP/RNBQKBNR b KQkq - 0 3","path":["d4","d5","e4","d6"]}
     ] |}

let diagram_data = parse_diagrams_json diagrams_json_stringified

let game_tex = to_tex ~diagram_data ~clock:false pgn
```

This will return a LaTex markdown representation of the PGN file along with chess board diagrams at the specified ply. Clock times can be rendered for both sides if you pass `~clock:true` to the `to_tex` function.

Each diagram is placed at the position identified by its path — the SAN move sequence from the start of the game (e.g. ["d4","d5","e4","d6"]). `path` uniquely identifies positions in both the mainline and in variations, and diagrams inside a variation are rendered inline within that variation. The legacy `ply` field is still accepted and used as a fallback for mainline diagrams when path is omitted.

Variation diagrams are rendered at a slightly smaller size (smallboard) so they don't dominate the subline. Clock times can be rendered for both sides by passing ~clock:true to to_tex.

## Supported headers

The following PGN headers are rendered:

- `Event` is used as the title when `Title` is absent.
- `Title` is rendered as the document title. When `Subtitle` is also present it
  is rendered below the title; a title without a subtitle renders no subtitle
  block.
- `Author` is rendered as the author line when present. Otherwise the author
  line is built from `White` and `Black`, including `WhiteElo` and `BlackElo`
  when supplied.
- `Date` and `Site` are combined into the date line. An empty date with a site
  renders the site; an empty date and site renders an empty date.
- `Result` is rendered in bold at the end of the game.

All other headers are ignored.

## NAG annotations

The following Numeric Annotation Glyphs are rendered:

| NAG | LaTeX |
| --- | --- |
| `$1` | `!` |
| `$2` | `?` |
| `$3` | `!!` |
| `$4` | `??` |
| `$5` | `!?` |
| `$6` | `?!` |
| `$10` | `=` |
| `$13` | `\infty` |
| `$14` | `\wbetter` |
| `$15` | `\bbetter` |
| `$16` | `\pm` |
| `$17` | `\mp` |
| `$18` | `+-` |
| `$19` | `-+` |
| `$22` | `\zugzwang` |
| `$32` | `\development` |
| `$36` | `\initiative` |
| `$40` | `\attack` |
| `$44` | `\compensation` |
| `$132` | `\counterplay` |

Unmapped NAGs are ignored.

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
