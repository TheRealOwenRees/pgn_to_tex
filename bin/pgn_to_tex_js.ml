open Js_of_ocaml
open Pgn_to_tex

let convert_js pgn_js diagram_json_js display_clock =
  let pgn = Js.to_string pgn_js in

  (* convert JS string into OCaml string *)
  let json_str = Js.to_string diagram_json_js in

  let diagram_data =
    if json_str = "" || json_str = "{}" then Pgn_to_tex.empty_diagrams
    else Pgn_to_tex.parse_diagrams_json json_str
  in

  let result = Pgn_to_tex.to_tex ~diagram_data ~clock:display_clock pgn in
  Js.string result

(* Exporting the module to the global JavaScript scope, including when the
   artifact is loaded as a CommonJS module in Node. *)
let () =
  let callback = Js.wrap_callback convert_js in
  Js.export "to_tex" callback;
  Js.Unsafe.set Js.Unsafe.global "to_tex" callback
