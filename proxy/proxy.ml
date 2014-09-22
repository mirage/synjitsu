open V1_LWT
open Printf
open Lwt

module Main (C: CONSOLE) (S: STACKV4) = struct

  module I = Init.Main(C)(S)

  let () =
    Arpv4.enable_promiscuous_mode ()

  let start c s =
    Tcpv4.Pcb.set_mode `Fast_start_proxy;
    I.start c s >>= fun _ip ->
    (* listen on all ports *)
    S.listen_tcpv4 s (-1) (fun _ -> return_unit);
    S.listen s

end
