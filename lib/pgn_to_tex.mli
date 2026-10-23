(** Convert chess PGN games to LaTeX.

    [Pgn_to_tex] is the public entry point for the library. Open it to convert a
    PGN string without referring to any internal parsing or rendering modules:

    {[
    let tex = Pgn_to_tex.to_tex pgn
    ]}

    Diagrams are optional and selected by passing {!diagram_data} built with
    {!empty_diagrams} or {!parse_diagrams_json}. *)

type diagram_data
(** Diagram selection data.

    The representation is intentionally abstract; construct values with
    {!empty_diagrams} or {!parse_diagrams_json}. *)

val empty_diagrams : diagram_data
(** [empty_diagrams] selects no diagrams. It is the default used by {!to_tex}.
*)

val parse_diagrams_json : string -> diagram_data
(** [parse_diagrams_json json] parses diagram selections from a JSON string.

    The input is expected to be a JSON array of objects. Each object contains a
    [fen] string and either a legacy [ply] number, a [path] array of SAN moves,
    or both. A matching [path] takes precedence; [ply] is the fallback for
    mainline positions. Malformed JSON yields {!empty_diagrams} rather than
    raising. *)

val to_tex : ?diagram_data:diagram_data -> ?clock:bool -> string -> string
(** [to_tex pgn] converts the PGN game in [pgn] to a LaTeX fragment.

    @param diagram_data
      diagram selections to render; defaults to {!empty_diagrams}.
    @param clock
      when [true], render clock times alongside diagrams; defaults to [false].

    Raises [Failure "Parse error"] if [pgn] is not a valid PGN game. *)
