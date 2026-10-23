module MoveMap = Ast.MoveMap
module PathMap = Ast.PathMap

(* escape strings for LaTeX *)
let escape_tex s =
  let b = Buffer.create (String.length s) in
  String.iter
    (fun c ->
      match c with
      | '#' -> Buffer.add_string b "\\#"
      | '%' -> Buffer.add_string b "\\%"
      | '{' -> Buffer.add_string b "\\{"
      | '}' -> Buffer.add_string b "\\}"
      | '_' -> Buffer.add_string b "\\_"
      | '&' -> Buffer.add_string b "\\&"
      | _ -> Buffer.add_char b c)
    s;
  Buffer.contents b

(* ELO string builder *)
let build_elo_string elo = if String.length elo > 0 then "(" ^ elo ^ ")" else ""

(* Author string builder *)
let build_author_string author white black white_elo black_elo =
  if author <> "" then "\\author{" ^ escape_tex author ^ "}"
  else
    match (white, black) with
    | "", "" -> "\\author{}"
    | white, black ->
        "\\author{" ^ escape_tex white ^ " " ^ build_elo_string white_elo
        ^ "\\\\" ^ escape_tex black ^ " " ^ build_elo_string black_elo ^ "}"

(* Title string builder *)
let build_title_string event title subtitle =
  match (event, title, subtitle) with
  | event, "", "" -> "\\title{" ^ event ^ "}"
  | _event, "", subtitle -> "\\title{" ^ subtitle ^ "}"
  | _event, title, "" -> "\\title{" ^ title ^ "}"
  | _event, title, subtitle ->
      "\\title{" ^ title ^ "\\\\[2ex]\\large{" ^ subtitle ^ "}}"

(* Date and Site string builder *)
let build_date_site_string date site =
  match (date, site) with
  | "", "" -> "\\date{}"
  | "", s -> "\\date{" ^ s ^ "}"
  | d, "" -> "\\date{" ^ d ^ "}"
  | d, s -> "\\date{" ^ d ^ ", " ^ s ^ "}"

(* board size options: mainline diagrams use the default size, variation
   diagrams use the smaller "smallboard" so they don't dominate the subline *)
let board_options small = if small then ", smallboard" else ""

(* emit a diagram with or without clock times *)
let diagram_tex ?(clock = false) ?(white_time = "0:00") ?(black_time = "0:00")
    ?(small = false) fen =
  let size = board_options small in
  if not clock then
    "\n\\par\\nobreak\\medskip\\chessboard[setfen=" ^ fen ^ ", vmargin=false"
    ^ size ^ "]\\par\\medskip\n"
  else
    "\\par\\medskip\\noindent" ^ "\\begin{minipage}{\\linewidth}" ^ black_time
    ^ "\\par\\nopagebreak\\smallskip\n" ^ "\\chessboard[setfen=" ^ fen
    ^ ", vmargin=false" ^ size ^ "]\\par\\nopagebreak\\vspace{1em}\n"
    ^ white_time ^ "\\end{minipage}\\par\\medskip"

(* look up a diagram by its SAN path (root -> position, space separated) *)
let get_diagram_by_path ?(clock = false) ?(white_time = "0:00")
    ?(black_time = "0:00") ?(small = false) ~path diagram_data =
  match PathMap.find_opt path diagram_data.Ast.by_path with
  | None -> None
  | Some fen -> Some (diagram_tex ~clock ~white_time ~black_time ~small fen)

(* look up a diagram by ply (legacy mainline keying) *)
let get_diagram_by_ply ?(clock = false) ?(white_time = "0:00")
    ?(black_time = "0:00") ply diagram_data =
  match MoveMap.find_opt ply diagram_data.Ast.by_ply with
  | None -> None
  | Some fen -> Some (diagram_tex ~clock ~white_time ~black_time fen)

(* Prefer the path lookup, falling back to ply for older payloads that only
   carry a mainline ply. *)
let get_diagram ?(clock = false) ?(white_time = "0:00") ?(black_time = "0:00")
    ?(small = false) ?path ~ply diagram_data =
  let by_path =
    match path with
    | Some path ->
        get_diagram_by_path ~clock ~white_time ~black_time ~small ~path
          diagram_data
    | None -> None
  in
  match by_path with
  | Some _ as diagram -> diagram
  | None -> get_diagram_by_ply ~clock ~white_time ~black_time ply diagram_data
