open Js_of_ocaml
open Pgn_logic
open Ast

let parse_diagram_json json_str =
  let json = Yojson.Basic.from_string json_str in
  let json_list = Yojson.Basic.Util.to_list json in

  List.fold_left
    (fun acc item ->
      let move_int =
        item |> Yojson.Basic.Util.member "ply" |> Yojson.Basic.Util.to_int
      in
      let fen_str =
        item |> Yojson.Basic.Util.member "fen" |> Yojson.Basic.Util.to_string
      in
      Pgn2tex.MoveMap.add move_int fen_str acc)
    Pgn2tex.MoveMap.empty json_list

let convert_js pgn_js diagram_json_js display_clock =
  let pgn = Js.to_string pgn_js in

  (* convert JS string into OCaml string *)
  let json_str = Js.to_string diagram_json_js in

  let diagram_data =
    if json_str = "" || json_str = "{}" then Pgn2tex.MoveMap.empty
    else parse_diagram_json json_str
  in

  let result = Pgn2tex.to_tex pgn ~diagram_data ~clock:display_clock in
  Js.string result

let to_tex pgn ~diagram_data ~clock = Pgn2tex.to_tex pgn ~diagram_data ~clock

(* Exporting the module to the global JavaScript scope *)
let () = Js.export "to_tex" (Js.wrap_callback convert_js)
