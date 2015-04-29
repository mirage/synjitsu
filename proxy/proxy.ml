open V1_LWT
open Printf
open Lwt

module Main (C: CONSOLE) (S: STACKV4) = struct

  module I = Init.Main(C)(S)

  let start c s =
    Tcp.Pcb.set_mode `Synjitsu;
    I.start c s >>= fun _ip ->

    (* clean-up previous proxy state *)
    OS.Xs.make () >>= fun xs ->
    I.dirs c xs [] >>= fun dirs ->
    Lwt_list.iter_p (fun ip -> I.remove c xs [ip]) dirs >>= fun () ->

    (* listen on all ports *)
    S.listen_tcpv4 s (-1) (fun _ -> return_unit);
    S.listen s

end
