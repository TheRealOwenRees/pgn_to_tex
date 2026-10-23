open OUnit2
open Pgn_to_tex_internal
open Ast

let ae expected actual = assert_equal expected actual

let test_empty_input _ctxt =
  ae { tags = []; content = []; result = None } (Parsing.parse_pgn "")

let test_result_only_game _ctxt =
  ae
    { tags = []; content = [ Result "1-0" ]; result = None }
    (Parsing.parse_pgn "1-0")

let test_nested_variations _ctxt =
  let pgn = "1. e4 (1. d4 (1... d5) 1... e5) 1... c5" in
  let expected =
    {
      tags = [];
      content =
        [
          Number "1.";
          Move "e4";
          Variation
            [
              Number "1.";
              Move "d4";
              Variation [ Number "1..."; Move "d5" ];
              Number "1...";
              Move "e5";
            ];
          Number "1...";
          Move "c5";
        ];
      result = None;
    }
  in
  ae expected (Parsing.parse_pgn pgn)

let test_malformed_input_raises _ctxt =
  assert_raises (Failure "Parse error") (fun () ->
      ignore (Parsing.parse_pgn "1. e4 e5 (2. Nf3"))

let suite =
  "parser tests"
  >::: [
         "empty_input" >:: test_empty_input;
         "result_only_game" >:: test_result_only_game;
         "nested_variations" >:: test_nested_variations;
         "malformed_input_raises" >:: test_malformed_input_raises;
       ]
