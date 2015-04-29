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

  let xs_key = function
    | [] -> "/ip"
    | k  ->
      let k = "/ip/" ^ String.concat "/" k in
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

  let writev c xs kvs =
    let kvs = List.map (fun (k, v) -> xs_key k, v) kvs in
    let str =
      String.concat " " (List.map (fun (k, v) -> sprintf "%s:%s" k v) kvs)
    in
    C.log_s c (sprintf "write %s\n" str) >>= fun () ->
    OS.Xs.(transaction xs (fun h ->
        Lwt_list.iter_p (fun (k, v) -> write h k v) kvs
      ))

  let dirs c xs k =
    let k = xs_key k in
    C.log_s c (sprintf "directory %s\n" k) >>= fun () ->
    OS.Xs.(immediate xs (fun h -> directory h k)) >>= fun dirs ->
    List.map (fun dir ->
        mutate_string (function '-' -> '.' | c -> c) dir
      ) dirs
    |> return

  let start c s =
    OS.Xs.make () >>= fun xs ->
    let module KV: Tcp.KV.S = struct
      type t = unit
      type step = string
      type key = string list
      type value = string
      let create () = Lwt.return_unit
      let read () = read c xs
      let writev () = writev c xs
      let remove () = remove c xs
      let dirs () = dirs c xs
    end in
    Tcp.KV.Global.set (module KV);
    let ips = S.IPV4.get_ip (S.ipv4 s) in
    let ips_str = String.concat ", " (List.map Ipaddr.V4.to_string ips) in
    C.log_s c  (sprintf "IP address: %s\n" ips_str) >>= fun () ->
    return ips

end
