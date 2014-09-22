open V1_LWT
open Printf
open Lwt

module Main (C: CONSOLE) (S: STACKV4) = struct

  module I = Init.Main(C)(S)

  let () =
    Arpv4.disable_promiscuous_mode ()

  let start c s =
    Tcpv4.Pcb.set_mode `Fast_start_app;
    I.start c s >>= fun _ip ->
    S.listen_tcpv4 s 42 (fun _ -> C.log_s c "\033[32mReceived a packet on port 42");
    S.listen_tcpv4 s 80 (fun _ -> C.log_s c "\033[33mReceived a packet on port 80");
    S.listen s

end
