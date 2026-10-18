open Js_of_ocaml
open Pgn_logic
open Ast

let convert_js pgn_js diagram_json_js display_clock =
  let pgn = Js.to_string pgn_js in

  (* convert JS string into OCaml string *)
  let json_str = Js.to_string diagram_json_js in

  let diagram_data =
    if json_str = "" || json_str = "{}" then Ast.empty_diagrams
    else Pgn2tex.parse_diagrams_json json_str
  in

  let result = Pgn2tex.to_tex pgn ~diagram_data ~clock:display_clock in
  Js.string result

(* Exporting the module to the global JavaScript scope *)
let () = Js.export "to_tex" (Js.wrap_callback convert_js)
