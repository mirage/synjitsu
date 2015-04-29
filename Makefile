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
	make -C proxy clean
	make -C app clean
