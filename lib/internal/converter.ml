module MoveMap = Ast.MoveMap
module PathMap = Ast.PathMap
open Yojson.Safe.Util

let path_key path_moves = String.concat " " path_moves

let parse_diagrams_json diagrams_json_str =
  let fail () = raise Exit in
  try
    let json = Yojson.Safe.from_string diagrams_json_str in
    let diagrams_list = to_list json in
    List.fold_left
      (fun acc item ->
        let fields = match item with `Assoc fields -> fields | _ -> fail () in
        let fen =
          match List.assoc_opt "fen" fields with
          | Some (`String fen) -> fen
          | _ -> fail ()
        in
        let acc =
          match List.assoc_opt "ply" fields with
          | None -> acc
          | Some (`Int ply) ->
              { acc with Ast.by_ply = MoveMap.add ply fen acc.Ast.by_ply }
          | Some _ -> fail ()
        in
        match List.assoc_opt "path" fields with
        | None -> acc
        | Some (`List path_items) ->
            let key = path_items |> List.map to_string |> path_key in
            { acc with Ast.by_path = PathMap.add key fen acc.Ast.by_path }
        | Some _ -> fail ())
      Ast.empty_diagrams diagrams_list
  with _ -> Ast.empty_diagrams

let to_tex pgn ~diagram_data ~clock =
  let game = Parsing.parse_pgn pgn in
  Latex.game_to_tex game ~diagram_data ~clock
