Optional:
```
git clone git://gitub.com/djs55/mirage-xen-minios -b minios-gntmap
make -C mirage-xen-minios depend
opam pin add mirage-xen-minios mirage-xen-minios -n
opam pin add mirage-xen git://github.com/djs55/mirage-platform#minios-gntmap -n
opam pin add xen-gnt git://github.com/djs55/ocaml-gnt#minios-gntmap
```

Mandatory:
```
opam pin add tcpip https://github.com/samoht/mirage-tcpip#synjitsu
sudo make init
make
# Edit the .xl files to:
#   (i) uncomment the VIF line; and
#  (ii) set the memory to 16 (instead of 256)
xl create -c proxy/synjitsu.xl
xl create -c fast-start/fast-start.xl
```
