open Mirage

let main = foreign "Synjitsu.Main" (console @-> network @-> stackv4 @-> job)

let ipv4_config =
  let address = Ipaddr.V4.of_string_exn "192.168.2.140" in
  let netmask = Ipaddr.V4.of_string_exn "255.255.255.0" in
  let gateways = [Ipaddr.V4.of_string_exn "192.168.2.1"] in
  { address; netmask; gateways }

let stack = direct_stackv4_with_static_ipv4 default_console tap0 ipv4_config

let platform =
    match get_mode () with
        | `Xen -> "xen"
        | _ -> "unix"

let () =
    add_to_opam_packages [
        "mirage-conduit" ;
        "cstruct" ;
        "mirage-" ^ platform;
        "mirage-vnetif" ;
        "mirage-net-" ^ platform;
        "mirage-clock-" ^ platform;
        "mirage-" ^ platform;
        "mirage-types" ;
        "tcpip" ];
    add_to_ocamlfind_libraries [
        "mirage-vnetif" ;
        "mirage-net-" ^ platform ;
        "mirage-" ^ platform;
        "mirage-clock-" ^ platform;
        "tcpip.stack-direct" ;
        "cstruct" ;
        "cstruct.syntax" ;
        "conduit" ;
        "conduit.mirage-xen" ;
        "mirage-types" ];
    register "synjitsu" [ main $ default_console $ tap0 $ stack ]
