open OUnit2

let contains = Helpers.Text_helper.contains

let read_file path =
  let ic = In_channel.open_text path in
  Fun.protect
    ~finally:(fun () -> In_channel.close ic)
    (fun () -> In_channel.input_all ic)

let render_fixture filename =
  Pgn_to_tex.to_tex (read_file @@ "pgn_examples/" ^ filename)

let all_percents_escaped text =
  let rec loop i =
    if i >= String.length text then true
    else if text.[i] = '%' then i > 0 && text.[i - 1] = '\\' && loop (i + 1)
    else loop (i + 1)
  in
  loop 0

let test_author_with_players _ctxt =
  let pgn =
    {|[Event "Club Night"]
[White "Alice"]
[Black "Bob"]
[Author "Carol"]
[Date "2024.01.02"]

1. e4 e5 1-0
|}
  in
  let tex = Pgn_to_tex.to_tex pgn in
  assert_bool "author header should be present"
    (contains ~needle:"\\author{Carol}" tex);
  assert_bool "author header should not be empty"
    (not (contains ~needle:"\\author{}" tex));
  assert_bool "player names should not replace the author"
    (not (contains ~needle:"Alice" tex))

let test_title_without_subtitle _ctxt =
  let pgn =
    {|[Event "Club Night"]
[Title "Club Championship"]
[Date "2024.01.02"]

1. e4 e5 1-0
|}
  in
  let tex = Pgn_to_tex.to_tex pgn in
  assert_bool "title should be rendered"
    (contains ~needle:"\\title{Club Championship}" tex);
  assert_bool "empty subtitle block should be omitted"
    (not (contains ~needle:"\\large{}" tex));
  assert_bool "subtitle separator should be omitted"
    (not (contains ~needle:"\\\\[2ex]" tex))

let test_title_subtitle_author_fixture _ctxt =
  let expected =
    {|\title{Some Title\\[2ex]\large{Some Subtitle}}
\author{Some Author}
\date{2025.12.23}\maketitle
\newchessgame
\textbf{1.} \textbf{d4} \textbf{d5} \textbf{2.} \textbf{c4} \textbf{dxc4} \textbf{3.} \textbf{e4} \textbf{Nf6} \textbf{4.} \textbf{e5} \textbf{Nd5} \textbf{5.} \textbf{Bxc4} \textbf{Nb6} \textbf{6.} \textbf{Bb3} \textbf{e6} ( 6... Nc6 ) \textbf{7.} \textbf{Nf3} \textbf{c5} \textbf{8.} \textbf{Be3} \textbf{N8d7} \textbf{9.} \textbf{O-O} \textbf{c4} \textbf{10.} \textbf{Bc2} \textbf{Nd5} \textbf{11.} \textbf{Nc3} \textbf{N7b6} \textbf{12.} \textbf{Be4} \textbf{Bb4} \textbf{13.} \textbf{Bxd5} \textbf{Nxd5} ( 13... Bxc3 ) \textbf{14.} \textbf{Nxd5} \textbf{exd5} \textbf{15.} \textbf{Qa4+} \textbf{Bd7} \textbf{16.} \textbf{Qxb4} \textbf{Qb6} \textbf{17.} \textbf{Qxb6} \textbf{axb6} \textbf{18.} \textbf{Rfc1} \textbf{O-O} \textbf{19.} \textbf{Nd2} \textbf{Bf5} \textbf{20.} \textbf{b3} \textbf{b5} \textbf{21.} \textbf{a4} \textbf{cxb3} \textbf{22.} \textbf{Nxb3} \textbf{bxa4} \textbf{23.} \textbf{Nc5} \textbf{b5} \textbf{24.} \textbf{Bd2} \textbf{Rfe8} \textbf{25.} \textbf{Bb4} \textbf{Rac8} \textbf{26.} \textbf{Nb7} \textbf{Rxc1+} \textbf{27.} \textbf{Rxc1} \textbf{Rc8} \textbf{28.} \textbf{Rxc8+} \textbf{Bxc8} \textbf{29.} \textbf{Nd6} \textbf{Bd7} \textbf{30.} \textbf{f4} \textbf{g6} \textbf{31.} \textbf{Kf2} \textbf{Kg7} \textbf{32.} \textbf{h3} \textbf{*}|}
  in
  assert_equal ~printer:(fun x -> x) expected (render_fixture "12.pgn")

let test_empty_date_and_site_fixture_5 _ctxt =
  let tex = render_fixture "5.pgn" in
  assert_bool "event title should be rendered"
    (contains ~needle:"\\title{Obert Barad 2024}" tex);
  assert_bool "players should be rendered when no author is present"
    (contains ~needle:"\\author{Alejandro Fernandez Cardenete (1873)" tex);
  assert_bool "empty date and site should render an empty date"
    (contains ~needle:"\\date{}\\maketitle" tex)

let test_empty_date_fixture_6 _ctxt =
  let tex = render_fixture "6.pgn" in
  assert_bool "empty date should fall back to the site"
    (contains ~needle:"\\date{Terrassa}\\maketitle" tex);
  assert_bool "a missing date must not render a comma-only date"
    (not (contains ~needle:"\\date{,}" tex))

let test_percent_escaping_fixture_8 _ctxt =
  let tex = render_fixture "8.pgn" in
  assert_bool "percent in a comment should be LaTeX-escaped"
    (contains ~needle:"\\%" tex);
  assert_bool "every percent in the output should be escaped"
    (all_percents_escaped tex)

let fixture_names () =
  Sys.readdir "pgn_examples" |> Array.to_list
  |> List.filter (fun name -> Filename.check_suffix name ".pgn")
  |> List.sort String.compare

let test_fixture_smoke =
  List.map
    (fun filename ->
      filename >:: fun _ctxt ->
      let tex = render_fixture filename in
      assert_bool
        (filename ^ " should render non-empty LaTeX")
        (String.length tex > 0);
      assert_bool
        (filename ^ " should contain document setup")
        (contains ~needle:"\\newchessgame" tex))
    (fixture_names ())

let suite =
  "real-world header and fixture tests"
  >::: [
         "author with players" >:: test_author_with_players;
         "title without subtitle" >:: test_title_without_subtitle;
         "title/subtitle/author fixture" >:: test_title_subtitle_author_fixture;
         "empty date/site fixture 5" >:: test_empty_date_and_site_fixture_5;
         "empty date fixture 6" >:: test_empty_date_fixture_6;
         "percent escaping fixture 8" >:: test_percent_escaping_fixture_8;
         "all fixtures" >::: test_fixture_smoke;
       ]
