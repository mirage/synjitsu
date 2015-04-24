(*
 * Copyright (c) 2010-2011 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2015 Magnus Skjegstad <magnus@skjegstad.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

(* Code extracted and adapted from Mirage TCP/IP stack *)
open Lwt_unix
open Lwt

module Make(Ethif : V1_LWT.ETHIF) = struct

  type arp = {
    op: [ `Request |`Reply |`Unknown of int ];
    sha: Macaddr.t;
    spa: Ipaddr.V4.t;
    tha: Macaddr.t;
    tpa: Ipaddr.V4.t;
  }

  cstruct arp {
    uint8_t dst[6];
    uint8_t src[6];
    uint16_t ethertype;
    uint16_t htype;
    uint16_t ptype;
    uint8_t hlen;
    uint8_t plen;
    uint16_t op;
    uint8_t sha[6];
    uint32_t spa;
    uint8_t tha[6];
    uint32_t tpa;
  } as big_endian

  let output t arp =
    (* Obtain a buffer to write into *)
    let buf = Cstruct.create sizeof_arp in
    (* Write the ARP packet *)
    let dmac = Macaddr.to_bytes arp.tha in
    let smac = Macaddr.to_bytes arp.sha in
    let spa = Ipaddr.V4.to_int32 arp.spa in
    let tpa = Ipaddr.V4.to_int32 arp.tpa in
    let op =
      match arp.op with
      |`Request -> 1
      |`Reply -> 2
      |`Unknown n -> n
    in
    set_arp_dst dmac 0 buf;
    set_arp_src smac 0 buf;
    set_arp_ethertype buf 0x0806; (* ARP *)
    set_arp_htype buf 1;
    set_arp_ptype buf 0x0800; (* IPv4 *)
    set_arp_hlen buf 6; (* ethernet mac size *)
    set_arp_plen buf 4; (* ipv4 size *)
    set_arp_op buf op;
    set_arp_sha smac 0 buf;
    set_arp_spa buf spa;
    set_arp_tha dmac 0 buf;
    set_arp_tpa buf tpa;
    Ethif.write t buf

  (* Send a gratuitous ARP for our IP addresses *)
  let output_garp t mac ips =
    let tha = Macaddr.broadcast in
    let sha = mac in
    let tpa = Ipaddr.V4.any in
    Lwt_list.iter_s (fun spa ->
        (*printf "ARP: sending gratuitous from %s\n%!" (Ipaddr.V4.to_string spa);*)
        output t { op=`Reply; tha; sha; tpa; spa }
      ) ips

end
