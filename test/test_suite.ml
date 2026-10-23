open OUnit2

let () =
  let all =
    "all tests"
    >::: [
           Test_lexer.suite;
           Test_latex.suite;
           Test_pgn_to_tex.suite;
           Test_parser.suite;
           Test_diagram_resolution.suite;
           Test_nag.suite;
           Test_real_world.suite;
         ]
  in
  run_test_tt_main all
