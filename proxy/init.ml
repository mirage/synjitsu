open V1_LWT
open Printf
open Lwt

module Main (C: CONSOLE) (S: STACKV4) = struct

  let xs_key k =
    let k = "/ip/" ^ k in
    String.iteri (fun i -> function
        | '.' -> k.[i] <- '-'
        | _   -> ()
      ) k;
    k

  let read c xs k =
    let k = xs_key k in
    C.log_s c (sprintf "read %s\n" k) >>= fun () ->
    Lwt.catch
      (fun () ->
         OS.Xs.(immediate xs (fun h -> read h k)) >>= fun v ->
         return (Some v))
      (function Xs_protocol.Enoent _ -> return_none | e -> fail e)

  let remove c xs k =
    let k = xs_key k in
    C.log_s c (sprintf "remove %s\n" k) >>= fun () ->
    OS.Xs.(immediate xs (fun h -> rm h k))

  let write c xs k v =
    let k = xs_key k in
    C.log_s c (sprintf "write %s %s\n" k v) >>= fun () ->
    OS.Xs.(immediate xs (fun h -> write h k v))

  let start c s =
    OS.Xs.make () >>= fun xs ->
    Tcpv4.Pcb.KV.set (read c xs) (write c xs) (remove c xs);
    let ip = S.IPV4.get_ipv4 (S.ipv4 s) in
    C.log_s c  (sprintf "IP address: %s\n" (Ipaddr.V4.to_string ip))
    >>= fun () ->
    return ip

end
