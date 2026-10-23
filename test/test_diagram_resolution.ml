open OUnit2

let contains ~needle haystack =
  let n = String.length needle and h = String.length haystack in
  let rec loop i =
    if i + n > h then false
    else if String.sub haystack i n = needle then true
    else loop (i + 1)
  in
  n = 0 || loop 0

let path_only_variation_json =
  {| [{"fen":"8/8/8/8/8/8/4K3/7k w - - 0 1","path":["e4","e5","Nf3","d6"]}] |}

let test_path_only_variation_diagram _ctxt =
  let pgn = "1. e4 e5 2. Nf3 Nc6 (2... d6) 3. Bb5" in
  let diagrams = Pgn_to_tex.parse_diagrams_json path_only_variation_json in
  let rendered = Pgn_to_tex.to_tex ~diagram_data:diagrams pgn in
  assert_bool
    (Printf.sprintf "path-only variation diagram missing from:\n%s" rendered)
    (contains ~needle:"setfen=8/8/8/8/8/8/4K3/7k w - - 0 1" rendered);
  assert_bool "path-only variation diagram should use smallboard"
    (contains ~needle:"smallboard" rendered)

let path_only_mainline_json =
  {| [{"fen":"8/8/8/8/8/8/4K3/7k w - - 0 1","path":["e4","e5"]}] |}

let test_path_only_mainline_diagram _ctxt =
  let pgn = "1. e4 e5 2. Nf3" in
  let diagrams = Pgn_to_tex.parse_diagrams_json path_only_mainline_json in
  let rendered = Pgn_to_tex.to_tex ~diagram_data:diagrams pgn in
  assert_bool
    (Printf.sprintf "path-only mainline diagram missing from:\n%s" rendered)
    (contains ~needle:"setfen=8/8/8/8/8/8/4K3/7k w - - 0 1" rendered)

let test_path_takes_precedence_over_ply _ctxt =
  let pgn = "1. e4 e5 2. Nf3" in
  let path_fen = "8/8/8/8/8/8/4K3/7k w - - 0 1" in
  let ply_fen = "7k/8/8/8/8/8/8/4K3 b - - 0 1" in
  let json =
    Printf.sprintf
      {| [{"fen":"%s","path":["e4","e5"]},{"ply":2,"fen":"%s"}] |} path_fen
      ply_fen
  in
  let diagrams = Pgn_to_tex.parse_diagrams_json json in
  let rendered = Pgn_to_tex.to_tex ~diagram_data:diagrams pgn in
  assert_bool "path diagram should win over the ply fallback"
    (contains ~needle:("setfen=" ^ path_fen) rendered);
  assert_bool "ply diagram should not replace the matching path diagram"
    (not (contains ~needle:("setfen=" ^ ply_fen) rendered))

let test_entry_with_path_and_ply _ctxt =
  let pgn = "1. e4 e5" in
  let both_fen = "8/8/8/8/8/8/4K3/7k w - - 0 1" in
  let path_fen = "7k/8/8/8/8/8/8/4K3 b - - 0 1" in
  let json =
    Printf.sprintf
      {| [{"ply":9,"fen":"%s","path":["e4"]},{"fen":"%s","path":["e4","e5"]}] |}
      both_fen path_fen
  in
  let diagrams = Pgn_to_tex.parse_diagrams_json json in
  let rendered = Pgn_to_tex.to_tex ~diagram_data:diagrams pgn in
  assert_bool "entry carrying both path and ply should still resolve by path"
    (contains ~needle:("setfen=" ^ both_fen) rendered);
  assert_bool "second path-only entry should resolve by path"
    (contains ~needle:("setfen=" ^ path_fen) rendered)

let test_ply_only_entry_falls_back _ctxt =
  let pgn = "1. e4 e5 2. Nf3" in
  let ply_fen = "7k/8/8/8/8/8/8/4K3 b - - 0 1" in
  let json = Printf.sprintf {| [{"ply":2,"fen":"%s"}] |} ply_fen in
  let diagrams = Pgn_to_tex.parse_diagrams_json json in
  let rendered = Pgn_to_tex.to_tex ~diagram_data:diagrams pgn in
  assert_bool "legacy ply-only diagram should still resolve by ply"
    (contains ~needle:("setfen=" ^ ply_fen) rendered)

let test_malformed_json_yields_empty_diagrams _ctxt =
  let pgn = "1. e4 e5" in
  let expected = Pgn_to_tex.to_tex pgn in
  let malformed =
    [
      "not json at all";
      {| {"ply":1} |};
      {| [{"path":["e4"]}] |};
      {| [{"fen":"8/8/8/8/8/8/4K3/7k w - - 0 1","ply":"not-a-number"}] |};
    ]
  in
  List.iter
    (fun json ->
      let actual =
        Pgn_to_tex.to_tex
          ~diagram_data:(Pgn_to_tex.parse_diagrams_json json)
          pgn
      in
      assert_equal ~printer:(fun x -> x)
        ~msg:("malformed JSON: " ^ json)
        expected actual)
    malformed

let suite =
  "diagram resolution tests"
  >::: [
         "path_only_variation_diagram" >:: test_path_only_variation_diagram;
         "path_only_mainline_diagram" >:: test_path_only_mainline_diagram;
         "path_takes_precedence_over_ply"
         >:: test_path_takes_precedence_over_ply;
         "entry_with_path_and_ply" >:: test_entry_with_path_and_ply;
         "ply_only_entry_falls_back" >:: test_ply_only_entry_falls_back;
         "malformed_json_yields_empty_diagrams"
         >:: test_malformed_json_yields_empty_diagrams;
       ]
