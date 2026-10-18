## 0.0.2

- support diagrams in variations. Diagram data now carries an optional `path` (the SAN move sequence from the root) alongside the legacy `ply`; diagrams whose `path` resolves inside a variation are rendered inline within the variation. `parse_diagrams_json` returns a `diagram_data` record with `by_ply` and `by_path` maps.

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
