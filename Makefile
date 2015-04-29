.PHONY: all clean proxy start init clean

all: proxy fast-start
	@

proxy:
	cd proxy && mirage configure --xen && make

fast-start:
	cd fast-start && mirage configure --xen && make

init:
	xenstore-write /ip ""
	xenstore-chmod /ip b0

clean:
	make -C proxy clean
	make -C fast-start clean
