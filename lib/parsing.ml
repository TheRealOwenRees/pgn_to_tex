open Ast

let in_header = ref false

let next_token buf =
  if !in_header then
    let tok = Lexer.tokenize_header buf in
    match tok with
    | Parser.TAG_CLOSE ->
        in_header := false;
        Parser.TAG_CLOSE
    | _ -> tok
  else
    let tok = Lexer.tokenize_game buf in
    match tok with
    | Parser.TAG_OPEN ->
        in_header := true;
        Parser.TAG_OPEN
    | _ -> tok

let parse_pgn s =
  let buf = Sedlexing.Utf8.from_string s in
  in_header := false;
  let provider () =
    let tok = next_token buf in
    let start_pos, end_pos = Sedlexing.lexing_positions buf in
    (tok, start_pos, end_pos)
  in
  try MenhirLib.Convert.Simplified.traditional2revised Parser.main provider
  with _ -> failwith "Parse error"

(* let parse_diagram_json json_str =
  let json = Yojson.Basic.from_string json_str in
  let json_assoc = Yojson.Basic.Util.to_assoc json in

  List.fold_left
    (fun acc (key_str, json_value) ->
      let value_string = Yojson.Basic.Util.to_string json_value in
      match int_of_string_opt key_str with
      | Some k -> Pgn2tex.MoveMap.add k value_string acc
      | None -> acc)
    Pgn2tex.MoveMap.empty json_assoc *)
