open Ast
open Latex_helpers

(* convert PGN headers to title tex *)
let tags_to_tex tags =
  let get_tag_value key tags ~default =
    match List.find_opt (fun t -> t.key = key) tags with
    | Some t -> t.value
    | None -> default
  in

  let white = get_tag_value "White" tags ~default:"" in
  let black = get_tag_value "Black" tags ~default:"" in
  let event = get_tag_value "Event" tags ~default:"" in
  let date = get_tag_value "Date" tags ~default:"" in
  let white_elo = get_tag_value "WhiteElo" tags ~default:"" in
  let black_elo = get_tag_value "BlackElo" tags ~default:"" in
  let site = get_tag_value "Site" tags ~default:"" in
  let title = get_tag_value "Title" tags ~default:"" in
  let subtitle = get_tag_value "Subtitle" tags ~default:"" in
  let author = get_tag_value "Author" tags ~default:"" in

  let title_tex = build_title_string event title subtitle in
  let author_tex = build_author_string author white black white_elo black_elo in

  title_tex ^ "\n" ^ author_tex ^ "\n"
  ^ build_date_site_string date site
  ^ "\\maketitle\n\\newchessgame"

let path_key path_moves = String.concat " " path_moves

let rec item_to_tex is_mainline ply ?(diagram_data = Ast.empty_diagrams)
    ?(branch_path = []) = function
  | Number n -> if is_mainline then "\\textbf{" ^ n ^ "}" else n
  | Move m ->
      if is_mainline then "\\textbf{" ^ escape_tex m ^ "}" else escape_tex m
  | Comment c ->
      if is_mainline then "\\newline " ^ escape_tex c ^ "\\par"
      else escape_tex c
  | Result r -> "\\textbf{" ^ r ^ "}"
  | Variation v ->
      "( " ^ render_game false ~diagram_data ~path:branch_path v ^ " )"
  | Nag g -> " " ^ Nag.nag_to_tex g ^ "{}"
  | Clock c -> c

and render_game is_mainline ?(diagram_data = Ast.empty_diagrams)
    ?(clock = false) ?(path = []) items =
  let rec aux ply interrupted ~white_time ~black_time ~path ~branch_path =
    function
    | [] -> ""
    | Comment c :: Move m :: tail when is_mainline && ply mod 2 != 0 ->
        let next_ply = ply + 1 in
        let next_path = path @ [ m ] in
        let rendered_comment = "\\newline " ^ escape_tex c ^ "\\par" in
        let rendered_move = "\\textbf{\\ldots{}" ^ escape_tex m ^ "}" in
        let diag_str =
          match
            get_diagram ~path:(path_key next_path) ~ply:next_ply diagram_data
          with
          | Some s -> s
          | None -> ""
        in
        let has_diag = diag_str <> "" in
        rendered_comment ^ " " ^ rendered_move ^ diag_str ^ " "
        ^ aux next_ply has_diag ~white_time ~black_time ~path:next_path
            ~branch_path:path tail
    | head :: tail -> (
        match head with
        | Clock c ->
            if ply mod 2 = 0 then
              aux ply interrupted ~white_time ~black_time:c ~path ~branch_path
                tail
            else
              aux ply interrupted ~white_time:c ~black_time ~path ~branch_path
                tail
        | _ ->
            let move_san = match head with Move m -> Some m | _ -> None in
            let is_move = Option.is_some move_san in

            let next_ply =
              match head with Move _ when is_mainline -> ply + 1 | _ -> ply
            in

            let next_path =
              match move_san with Some m -> path @ [ m ] | None -> path
            in

            let prefix =
              if is_move && is_mainline && next_ply mod 2 == 0 && interrupted
              then "\\ldots{}"
              else ""
            in

            let rendered_head =
              let raw_head =
                item_to_tex is_mainline next_ply ~diagram_data ~branch_path head
              in
              if prefix <> "" && raw_head <> "" then
                "\\textbf{" ^ prefix ^ "}" ^ raw_head
              else raw_head
            in

            let diag_str =
              if is_move then
                if is_mainline then
                  get_diagram ~path:(path_key next_path) ~ply:next_ply ~clock
                    ~white_time ~black_time diagram_data
                else
                  get_diagram_by_path ~path:(path_key next_path) ~small:true
                    diagram_data
              else None
            in

            let diag_output = match diag_str with Some s -> s | None -> "" in
            let is_comment = match head with Comment _ -> true | _ -> false in
            let next_interrupted = diag_output <> "" || is_comment in
            let next_branch_path = if is_move then path else branch_path in
            let rest =
              aux next_ply next_interrupted ~white_time ~black_time
                ~path:next_path ~branch_path:next_branch_path tail
            in

            if rendered_head = "" then rest
            else
              rendered_head ^ diag_output ^ if rest = "" then "" else " " ^ rest
        )
  in
  String.trim
    (aux 0 false ~white_time:"0:00" ~black_time:"0:00" ~path ~branch_path:path
       items)

let game_to_tex game ~diagram_data ~clock =
  let header_tex = tags_to_tex game.tags in
  let content_tex = render_game true ~diagram_data ~clock game.content in

  let result_tex =
    match game.result with Some r -> " \\textbf{" ^ r ^ "}" | None -> ""
  in

  header_tex ^ "\n" ^ content_tex ^ result_tex
