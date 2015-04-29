open V1_LWT
open Printf
open Lwt

module Main (C: CONSOLE) (S: STACKV4) = struct

  module I = Init.Main(C)(S)

  let rec start c s =
    Tcp.Pcb.set_mode `Synjitsu_app;
    I.start c s >>= fun _ip ->
    C.log_s c "Starting ....\n" >>= fun () ->
    S.listen_tcpv4 s 42 (fun _ -> C.log_s c "\033[32mReceived a packet on port 42\033[0m");
    S.listen_tcpv4 s 80 (fun _ -> C.log_s c "\033[33mReceived a packet on port 80\033[0m");
    S.listen s

end
