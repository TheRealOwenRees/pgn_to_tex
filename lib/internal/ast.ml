module MoveMap = Map.Make (Int)
module PathMap = Map.Make (String)

type tag = { key : string; value : string }

(* Diagrams selected by the client. [by_ply] keeps the legacy mainline lookup
   keyed on the ply number; [by_path] keys on the SAN move sequence from the
   root (space separated), which uniquely identifies mainline and variation
   positions alike. *)
type diagram_data = { by_ply : string MoveMap.t; by_path : string PathMap.t }

let empty_diagrams = { by_ply = MoveMap.empty; by_path = PathMap.empty }

type item =
  | Move of string
  | Number of string
  | Clock of string
  | Nag of string
  | Comment of string
  | Result of string
  | Variation of item list

type game = { tags : tag list; content : item list; result : string option }
