open V1_LWT
open Printf
open Lwt

module Main (C: CONSOLE) (S: STACKV4) = struct

  let mutate_string f s =
    String.iteri (fun i c ->
        let x = f c in
        if x = c then ()
        else s.[i] <- x
      ) s;
    s

  let xs_key k =
    let k = "/ip/" ^ k in
    mutate_string (function '.' -> '-' | x   -> x) k

  let safe_read h k =
    Lwt.catch
      (fun () -> OS.Xs.read h k >>= fun v -> return (Some v))
      (function Xs_protocol.Enoent _ -> return_none | e -> fail e)

  let read c xs k =
    let k = xs_key k in
    C.log_s c (sprintf "read %s\n" k) >>= fun () ->
    OS.Xs.(immediate xs (fun h -> safe_read h k))

  let remove c xs k =
    let k = xs_key k in
    C.log_s c (sprintf "remove %s\n" k) >>= fun () ->
    OS.Xs.(immediate xs (fun h -> rm h k))

  let write c xs kvs =
    let kvs = List.map (fun (k, v) -> xs_key k, v) kvs in
    let str =
      String.concat " " (List.map (fun (k, v) -> sprintf "%s:%s" k v) kvs)
    in
    C.log_s c (sprintf "write %s\n" str) >>= fun () ->
    OS.Xs.(transaction xs (fun h ->
        Lwt_list.iter_p (fun (k, v) -> write h k v) kvs
      ))

  let watch c xs k =
    let k = xs_key k in
    C.log_s c (sprintf "watch %s\n" k) >>= fun () ->
    OS.Xs.(wait xs (fun h ->
        safe_read h k >>= function
        | None   -> fail Xs_protocol.Eagain
        | Some _ -> return_unit
      ))

  let directory c xs k =
    let k = xs_key k in
    C.log_s c (sprintf "directory %s\n" k) >>= fun () ->
    OS.Xs.(immediate xs (fun h -> directory h k)) >>= fun dirs ->
    List.map (fun dir ->
        mutate_string (function '-' -> '.' | c -> c) dir
      ) dirs
    |> return

  let start c s =
    OS.Xs.make () >>= fun xs ->
    let module KV: Tcpv4.Pcb.KV.S = struct
      let read = read c xs
      let write = write c xs
      let remove = remove c xs
      let watch = watch c xs
      let directory = directory c xs
    end in
    Tcpv4.Pcb.KV.set (module KV);
    let ip = S.IPV4.get_ipv4 (S.ipv4 s) in
    C.log_s c  (sprintf "IP address: %s\n" (Ipaddr.V4.to_string ip))
    >>= fun () ->
    return ip

end
