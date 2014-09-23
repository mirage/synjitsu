.PHONY: all clean proxy start init clean

all: proxy fast-start
	@

proxy:
	cd proxy && mirage configure --xen

fast-start:
	cd fast-start && mirage configure --xen

init:
	xenstore-write /ip ""
	xenstore-chmod /ip b0

clean:
	make -C proxy clean
	make -C fast-start clean
