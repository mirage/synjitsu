```
opam pin add tcpip https://github.com/samoht/mirage-tcpip#fast-path
sudo make init
make
xl create -c proxy/synjitsu.xl
xl create -c fast-start/fast-start.xl
```
