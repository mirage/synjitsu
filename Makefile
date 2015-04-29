.PHONY: all clean app synjitsu start init clean

all:
	$(MAKE) proxy; $(MAKE) app

synjitsu:
	cd synjitsu && mirage configure --xen && make

app:
	cd app && mirage configure --xen && make

init:
	xenstore-write /ip ""
	xenstore-chmod /ip b0

clean:
	if [ -f synjitsu/Makefile ]; then make -C synjitsu clean; rm synjitsu/Makefile; fi
	if [ -f app/Makefile ]; then make -C app clean; rm app/Makefile; fi
