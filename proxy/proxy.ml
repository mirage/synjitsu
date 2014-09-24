open V1_LWT
open Printf
open Lwt

module Main (C: CONSOLE) (S: STACKV4) = struct

  module I = Init.Main(C)(S)

  let start c s =
    Tcpv4.Pcb.set_mode `Fast_start_proxy;
    I.start c s >>= fun _ip ->

    (* clean-up previous proxy state *)
    OS.Xs.make () >>= fun xs ->
    I.directory c xs "" >>= fun dirs ->
    Lwt_list.iter_p (I.remove c xs) dirs >>= fun () ->

    (* listen on all ports *)
    S.listen_tcpv4 s (-1) (fun _ -> return_unit);
    S.listen s

end
