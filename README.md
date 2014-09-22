```
opam pin add tcpip https://github.com/samoht/mirage-tcpip#fast-path
sudo make init
make
# Edit the .xl files to:
#   (i) uncomment the VIF line; and
#  (ii) set the memory to 16 (instead of 256)
xl create -c proxy/synjitsu.xl
xl create -c fast-start/fast-start.xl
```
