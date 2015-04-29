### Install

For now on, you need to pin `tcpip`:

```
opam pin add tcpip https://github.com/samoht/mirage-tcpip.git#synjistu
```

Then you can build the synjitsu proxy and an (very simple) example application:

```
make
```

### Run

You first need toset-up the `/ip/` path xenstore with the right access
control list. This can be done by:

```
sudo make init
```

You can then edit `proxy/synjitsu.xl` to:

1. uncomment the VIF line; and
2. set the memory to 16 (instead of 256)

And then you can boot the resulting unikernel:

```
sudo xl create -c proxy/synjitsu.xl
```

(same thing for the example application in `app/`)