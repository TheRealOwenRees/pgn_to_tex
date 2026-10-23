## 0.1.0

### Breaking changes

- Renamed the public entry point from `Pgn_logic` / `Pgn2tex` to
  `Pgn_to_tex`. The old modules are removed with no compatibility aliases.
- `Pgn_to_tex.to_tex` takes optional `~diagram_data` and `~clock` arguments
  before the PGN string, and defaults to no diagrams and no clock output.
- Removed the internal parser, AST, LaTeX, and NAG modules from the public
  surface. `diagram_data` is now an abstract type.
- Renamed the optional JavaScript artifact from `main.bc.js` to
  `pgn_to_tex_js.bc.js`.

### Added

- New public API: `Pgn_to_tex.to_tex`, `Pgn_to_tex.parse_diagrams_json`,
  `Pgn_to_tex.empty_diagrams`, and the abstract `diagram_data` type.
- Diagram JSON accepts `path`, `ply`, or both. Paths identify mainline and
  variation positions; path lookup takes precedence over the legacy ply
  fallback, and path-only variation entries are supported.
- Diagrams inside variations render inline at the smaller `smallboard` size.
- Generated odoc API documentation, a package landing page, and a GitHub Pages
  deployment workflow.
- GitHub Actions CI covering formatting, build, tests, docs, the JavaScript
  build, the Node smoke test, and opam lint.
- A self-contained README covering installation, the API, diagram JSON,
  clocks, variations, headers, NAGs, errors, the LaTeX preamble, and JavaScript
  usage.
- `js_of_ocaml` and `js_of_ocaml-ppx` are declared as test-only dependencies.

### Fixed

- A mixed `Author` and player header no longer produces an empty author line.
- A `Title` without a `Subtitle` no longer emits an empty subtitle block.

### Changed

- The package version is now `0.1.0`.
- Documentation now points at
  <https://therealowenrees.github.io/pgn_to_tex/>.
- Removed stale CI-acceptance metadata for unsupported OCaml versions.

### Migration from 0.0.x

Replace the old import and module prefix:

```ocaml
(* 0.0.x *)
open Pgn_logic

let diagrams = Pgn2tex.parse_diagrams_json json
let tex = Pgn2tex.to_tex pgn ~diagram_data:diagrams ~clock:false

(* 0.1.0 *)
let diagrams = Pgn_to_tex.parse_diagrams_json json
let tex = Pgn_to_tex.to_tex ~diagram_data:diagrams ~clock:false pgn
```

Use `Pgn_to_tex.empty_diagrams` when a game has no diagrams. Diagram data is
now abstract, so replace any hand-built `MoveMap.t` with
`Pgn_to_tex.parse_diagrams_json`. The JavaScript `to_tex` function keeps the
same three arguments; only the artifact name changed.

## 0.0.2

- support diagrams in variations. Diagram data now carries an optional `path` (the SAN move sequence from the root) alongside the legacy `ply`; diagrams whose `path` resolves inside a variation are rendered inline within the variation. `parse_diagrams_json` returns a `diagram_data` record with `by_ply` and `by_path` maps.

- make variation board diagrams slightly smaller than mainline board diagrams

## v0.0.1

- fix bug whereby a `subtitle` custom PGN header was rendering on a separate page. It now appears under the title
- remove old tests and commented out code

## v0.0.1-rc.2

- add correct versioning metadata

## v0.0.1-rc.1

- Update readme and add license file

## v0.0.1-alpha.2

- Expose function `parse_diagrams_json` to convert stringified JSON to a MoveMap, allowing for parsing of the diagram data with `to_tex`

## v0.0.1-alpha.1

- Initial release
