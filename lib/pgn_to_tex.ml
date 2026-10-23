type diagram_data = Pgn_to_tex_internal.Ast.diagram_data

let empty_diagrams = Pgn_to_tex_internal.Ast.empty_diagrams

let parse_diagrams_json = Pgn_to_tex_internal.Converter.parse_diagrams_json

let to_tex ?(diagram_data = empty_diagrams) ?(clock = false) pgn =
  Pgn_to_tex_internal.Converter.to_tex pgn ~diagram_data ~clock
