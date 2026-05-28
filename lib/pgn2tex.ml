module MoveMap = Ast.MoveMap
open Yojson.Safe.Util

let parse_diagrams_json diagrams_json_str =
  try
    let json = Yojson.Safe.from_string diagrams_json_str in
    let diagrams_list = to_list json in
    List.fold_left
      (fun acc_map item ->
        let ply = item |> member "ply" |> to_int in
        let fen = item |> member "fen" |> to_string in
        MoveMap.add ply fen acc_map)
      MoveMap.empty diagrams_list
  with _ -> MoveMap.empty

let to_tex pgn ~diagram_data ~clock =
  let game = Parsing.parse_pgn pgn in
  Latex.game_to_tex game ~diagram_data ~clock
