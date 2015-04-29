.PHONY: all clean app proxy start init clean

all:
	$(MAKE) proxy; $(MAKE) app

proxy:
	cd proxy && mirage configure --xen && make

app:
	cd app && mirage configure --xen && make

init:
	xenstore-write /ip ""
	xenstore-chmod /ip b0

clean:
	if [ -f proxy/Makefile ]; then make -C proxy clean; rm proxy/Makefile; fi
	if [ -f app/Makefile ]; then make -C app clean; rm app/Makefile; fi
