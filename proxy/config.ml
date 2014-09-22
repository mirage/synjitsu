open Mirage

let main = foreign "Proxy.Main" (console @-> stackv4 @-> job)

let ipv4_config =
  let address = Ipaddr.V4.of_string_exn "192.168.2.140" in
  let netmask = Ipaddr.V4.of_string_exn "255.255.255.0" in
  let gateways = [Ipaddr.V4.of_string_exn "192.168.2.1"] in
  { address; netmask; gateways }

let stack = direct_stackv4_with_static_ipv4 default_console tap0 ipv4_config

let () =
  register "synjitsu" [ main $ default_console $ stack ]
