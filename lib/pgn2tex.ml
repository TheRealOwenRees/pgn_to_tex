module MoveMap = Ast.MoveMap
module PathMap = Ast.PathMap
open Yojson.Safe.Util

let path_key path_moves = String.concat " " path_moves

let parse_diagrams_json diagrams_json_str =
  try
    let json = Yojson.Safe.from_string diagrams_json_str in
    let diagrams_list = to_list json in
    List.fold_left
      (fun acc item ->
        let ply = item |> member "ply" |> to_int in
        let fen = item |> member "fen" |> to_string in
        let acc =
          { acc with Ast.by_ply = MoveMap.add ply fen acc.Ast.by_ply }
        in
        match item |> member "path" with
        | `List path_items ->
            let key = path_items |> List.map to_string |> path_key in
            { acc with Ast.by_path = PathMap.add key fen acc.Ast.by_path }
        | _ -> acc)
      Ast.empty_diagrams diagrams_list
  with _ -> Ast.empty_diagrams

let to_tex pgn ~diagram_data ~clock =
  let game = Parsing.parse_pgn pgn in
  Latex.game_to_tex game ~diagram_data ~clock
