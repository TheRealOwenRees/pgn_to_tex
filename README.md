# Pgn_to_tex

`Pgn_to_tex` converts chess games written in PGN to LaTeX. It renders move
numbers, moves, comments, variations, NAG annotations, clock times, and
optional chessboard diagrams of selected positions.

- [API documentation](https://therealowenrees.github.io/pgn_to_tex/)
- [Changelog](CHANGELOG.md)
- [Contributing](CONTRIBUTING.md)

## Requirements

- OCaml 5.4 or newer
- dune
- A LaTeX installation with `xskak` and `multicol` (see
  [LaTeX setup](#latex-setup))

## Installation

Install the released package with opam:

```sh
opam install pgn_to_tex
```

To use the current repository instead, clone it and pin the checkout:

```sh
git clone https://github.com/TheRealOwenRees/pgn_to_tex.git
cd pgn_to_tex
opam install .
```

Then add the library to the relevant `dune` file:

```lisp
(libraries pgn_to_tex)
```

## Quick start

Open `Pgn_to_tex` and call `to_tex` with a PGN string:

```ocaml
let pgn = "1. e4 e5 2. Nf3 Nc6 3. Bb5"

let tex = Pgn_to_tex.to_tex pgn
```

`to_tex` returns a LaTeX fragment without a preamble or `\begin{document}`.
`~diagram_data` defaults to no diagrams and `~clock` defaults to `false`, so
this basic call needs no other arguments.

To render diagrams, describe the selected positions as JSON and parse it with
`parse_diagrams_json`:

```ocaml
let diagrams =
  Pgn_to_tex.parse_diagrams_json
    {| [
         {"fen": "rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1",
          "path": ["d4"]},
         {"fen": "rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 2",
          "ply": 2}
       ] |}

let tex = Pgn_to_tex.to_tex ~diagram_data:diagrams pgn
```

To explicitly request a game with no diagrams, pass
`~diagram_data:Pgn_to_tex.empty_diagrams`.

`diagram_data` is abstract. Construct it with `parse_diagrams_json` or
`empty_diagrams` instead of building the internal representation directly.

## Diagram JSON schema

`parse_diagrams_json` accepts a JSON array. Each entry is an object:

```json
[
  {"fen": "8/8/8/8/8/8/4K3/7k w - - 0 1", "path": ["d4", "d5", "e4", "d6"]},
  {"fen": "8/8/8/8/8/8/4K3/7k w - - 0 1", "ply": 5},
  {"fen": "8/8/8/8/8/8/4K3/7k w - - 0 1", "ply": 9, "path": ["e4", "e5", "Nf3", "Nc6"]}
]
```

| Field  | Type            | Required        | Description |
| ------ | --------------- | --------------- | ----------- |
| `fen`  | string          | yes             | The board position to render. |
| `path` | array of string | one of path/ply | The SAN move sequence from the start of the game, including moves inside a variation (for example `["d4","d5","e4","d6"]`). It uniquely identifies mainline and variation positions. |
| `ply`  | integer         | one of path/ply | Legacy half-move count from the start of the game: 1 after White's first move. It is used for mainline positions. |

Resolution rules:

- An entry may carry `path`, `ply`, or both.
- A matching `path` takes precedence over a matching `ply`.
- If no `path` matches, mainline positions fall back to a matching legacy `ply`.
- Variation diagrams require `path`; a `ply`-only entry only matches mainline
  positions.
- Missing both `path` and `ply` leaves the entry with no position to match.

Diagrams on the mainline use the default board size. Diagrams inside a
variation are rendered inline and use the smaller `smallboard` size.

### Malformed diagram JSON

If the JSON is invalid, or any entry is malformed, `parse_diagrams_json`
returns empty diagram data instead of raising. Conversion then proceeds
without diagrams.

## Clocks

Clock annotations are opt-in:

```ocaml
let tex = Pgn_to_tex.to_tex ~clock:true ~diagram_data:diagrams pgn
```

With `~clock:true`, the most recent clock values for both players are shown
above and below each rendered diagram. Clock values come from PGN clock
annotations such as `{[%clk 0:10:00]}` or an inline `[%clk 0:10:00]`.

Clocks are displayed as part of diagram output. When no diagram is selected
for a position, its clock values are not emitted.

## Variations

Parenthesised variations are rendered inline inside the mainline, for example
`( 2... d6 )`. Mainline moves and move numbers are bold; variation moves are
not. Comments and NAGs inside a variation are rendered there too. Variation
diagrams are looked up by their full `path` and use `smallboard` so they do not
dominate the subline.

## Supported headers

The following PGN headers are rendered:

- `Event` is used as the title when `Title` is absent.
- `Title` is the document title. When `Subtitle` is also present, the subtitle
  is rendered below the title. A title without a subtitle renders no subtitle
  block.
- `Author` is the author line when present. Otherwise the author line is built
  from `White` and `Black`, including `WhiteElo` and `BlackElo` when supplied.
- `Date` and `Site` are combined into the date line. An empty date with a site
  renders the site; an empty date and site render an empty date.
- `Result` is rendered in bold at the end of the game.

All other headers are ignored.

## NAG annotations

The following Numeric Annotation Glyphs are rendered:

| NAG    | LaTeX                   |
| ------ | ----------------------- |
| `$1`   | `!`                     |
| `$2`   | `?`                     |
| `$3`   | `!!`                    |
| `$4`   | `??`                    |
| `$5`   | `!?`                    |
| `$6`   | `?!`                    |
| `$10`  | `=`                     |
| `$13`  | `\infty`                |
| `$14`  | `\wbetter`              |
| `$15`  | `\bbetter`              |
| `$16`  | `\ensuremath{\pm}`      |
| `$17`  | `\ensuremath{\mp}`      |
| `$18`  | `+-`                    |
| `$19`  | `-+`                    |
| `$22`  | `\zugzwang`             |
| `$32`  | `\development`          |
| `$36`  | `\initiative`           |
| `$40`  | `\attack`               |
| `$44`  | `\compensation`         |
| `$132` | `\counterplay`          |

Unmapped NAGs are ignored.

## Error behavior

- `to_tex` raises `Failure "Parse error"` when the PGN cannot be parsed.
- `parse_diagrams_json` never raises for malformed JSON; it returns empty
  diagram data, as described above.

## LaTeX setup

The generated string is a fragment: it does not include a document class,
preamble, or `\begin{document}`. A complete document using `xskak` (which
loads `chessboard`, `skak`, and the chess symbol fonts), `multicol` for the
column layout, and the default diagram commands looks like this:

```latex
\documentclass{article}
\usepackage{xskak}
\usepackage{multicol}
\usepackage{amsmath,amssymb}

% NAG $13 renders \infty, a math-mode symbol, in text mode.
\let\pgninfinity\infty
\renewcommand{\infty}{\ensuremath{\pgninfinity}}

\begin{document}
\begin{multicols}{2}
% Paste the string returned by Pgn_to_tex.to_tex here.
\end{multicols}
\end{document}
```

The relevant packages are:

- `xskak` for `\newchessgame`, `\chessboard`, and the NAG symbol commands.
- `multicol` for the two-column environment shown above.
- `amsmath` and `amssymb` for math symbols.

## JavaScript build

The JavaScript target is optional. Dune skips it when the JavaScript
dependencies are not installed. Install them with:

```sh
opam install js_of_ocaml js_of_ocaml-ppx
```

Build the artifact with:

```sh
dune build bin/pgn_to_tex_js.bc.js
```

The generated CommonJS file is
`_build/default/bin/pgn_to_tex_js.bc.js`. It works in Node and in the browser.

The build exposes a single global function with the same three inputs as the
JavaScript entry point:

```js
to_tex(pgnString, diagramJsonString, displayClock);
```

- `pgnString` is the PGN text.
- `diagramJsonString` is the diagram JSON. Pass `""` or `"{}"` when there are
  no diagrams.
- `displayClock` is a boolean controlling clock rendering.
- The return value is the LaTeX fragment as a string.

Node example:

```js
require("./_build/default/bin/pgn_to_tex_js.bc.js");

const gameTex = globalThis.to_tex("1. e4 e5 2. Nf3", "{}", false);
```

In the browser, the function is available as `window.to_tex` after the
artifact is loaded.

Run the Node smoke test after building the artifact:

```sh
node test/js/smoke.js
```

## Migration from 0.0.x

Version `0.1.0` is a breaking release. The old `Pgn_logic` library name and the
`Pgn2tex` module are gone.

| 0.0.x | 0.1.0 |
| ----- | ----- |
| `open Pgn_logic` | `open Pgn_to_tex` or use `Pgn_to_tex.` |
| `Pgn2tex.to_tex` | `Pgn_to_tex.to_tex` |
| `Pgn2tex.parse_diagrams_json` | `Pgn_to_tex.parse_diagrams_json` |
| Exposed `MoveMap.t` diagram data | Abstract `Pgn_to_tex.diagram_data` |
| `_build/default/bin/main.bc.js` | `_build/default/bin/pgn_to_tex_js.bc.js` |

The optional arguments now come before the PGN string:

```ocaml
(* 0.0.x *)
let tex = Pgn2tex.to_tex pgn ~diagram_data ~clock:false

(* 0.1.0 *)
let tex = Pgn_to_tex.to_tex ~diagram_data ~clock:false pgn
```

Replace a hand-built diagram map with `parse_diagrams_json`, or use
`empty_diagrams` for a game without diagrams. Path-only diagram entries are
supported; see [Diagram JSON schema](#diagram-json-schema). The JavaScript
`to_tex(pgn, diagramJson, displayClock)` contract is unchanged apart from the
artifact name.

## Dependencies

Runtime and build dependencies:

- `ocaml` >= 5.4
- `dune` >= 3.21
- `sedlex` >= 3.7
- `menhir` >= 20260209
- `yojson` >= 3.0

Test-only dependencies:

- `ounit2` >= 2.2.7
- `js_of_ocaml`
- `js_of_ocaml-ppx`

Development and documentation dependencies:

- `ocamlformat` 0.29.0 (development setup)
- `odoc` (documentation build)

## License

AGPL-3.0-or-later. See [LICENSE](LICENSE).
