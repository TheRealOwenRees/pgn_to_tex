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

This will return a LaTex markdown representation of the PGN file along with chess board diagrams at the specified positions. Clock times can be rendered for both sides if you pass `~clock:true` to the `to_tex` function.

### Diagram JSON schema

`parse_diagrams_json` accepts a JSON array of objects:

```json
[
  {"fen": "...", "path": ["d4", "d5", "e4", "d6"]},
  {"fen": "...", "ply": 5},
  {"fen": "...", "ply": 9, "path": ["e4", "e5", "Nf3", "Nc6"]}
]
```

| Field  | Type            | Required          | Description                                                                                                                        |
| ------ | --------------- | ----------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `fen`  | string          | yes               | The board position to render.                                                                                                      |
| `path` | array of string | one of path/ply   | SAN move sequence from the start of the game (e.g. `["d4","d5","e4","d6"]`). It uniquely identifies mainline and variation positions. |
| `ply`  | integer         | one of path/ply   | Legacy half-move count from the start of the game (1 after White's first move). Used for mainline positions.                        |

Resolution rules:

- An entry may carry `path`, `ply`, or both.
- When a rendered position has a matching `path`, that diagram takes precedence.
- If no `path` matches, mainline positions fall back to a matching legacy `ply`.
- Variation diagrams require `path`; a `ply`-only entry only matches mainline positions.
- Malformed diagram JSON yields empty diagram data instead of raising.

Diagrams inside a variation are rendered inline within that variation and at a slightly smaller size (`smallboard`) so they don't dominate the subline.

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

The JavaScript build is an optional target. Dune skips it when the JavaScript dependencies are not installed. Install them with:

```
opam install js_of_ocaml js_of_ocaml-ppx
```

Then compile the code to JavaScript by running:

```
make build
```

or build just the artifact:

```
dune build bin/pgn_to_tex_js.bc.js
```

This generates the JavaScript file at `_build/default/bin/pgn_to_tex_js.bc.js`.

This JavaScript file is minified and in CJS format, working in both Node and the browser.

A single global `to_tex` function is exposed, accepting the same three arguments as the main library:

```js
to_tex(pgnString, diagramJsonString, displayClock);
```

For example:

```js
require("./_build/default/bin/pgn_to_tex_js.bc.js");

const gameTex = globalThis.to_tex("1. e4 e5 2. Nf3", "{}", false);
```

Pass `"{}"` (or an empty string) when there are no diagrams, and `false` to omit clock times. In the browser, the function is available as `window.to_tex` after loading the artifact.

After building the artifact, you can run the Node smoke test with:

```
node test/js/smoke.js
```

## Dependencies

- dune
- sedlex
- menhir
- yojson
- js_of_ocaml-compiler
- ocamlformat
- ocaml-lsp-server
- ounit2
