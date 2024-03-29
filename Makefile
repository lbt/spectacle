PYTHON ?= python
VERSION = $(shell cat VERSION)
TAGVER = $(shell cat VERSION | sed -e "s/\([0-9\.]*\).*/\1/")

ifeq ($(VERSION), $(TAGVER))
	TAG = $(TAGVER)
else
	TAG = "HEAD"
endif

ifndef PREFIX
    PREFIX = "/usr"
endif

all: tmpls
	$(PYTHON) setup.py build

tmpls:
	cd spectacle/spec; $(MAKE)
	cd spectacle/dsc; $(MAKE)

tag:
	git tag $(VERSION)

dist-bz2:
	git archive --format=tar --prefix=spectacle-$(VERSION)/ $(TAG) | \
		bzip2  > spectacle-$(VERSION).tar.bz2

dist-gz:
	git archive --format=tar --prefix=spectacle-$(VERSION)/ $(TAG) | \
		gzip  > spectacle-$(VERSION).tar.gz

doc:
	markdown README.md > README.html

test:
	cd tests/; $(PYTHON) alltest.py

install: all install-data
	$(PYTHON) setup.py install --root=${DESTDIR} --prefix=${PREFIX}

develop: all install-data
	$(PYTHON) setup.py develop

install-data:
	install -d ${DESTDIR}/usr/share/spectacle/
	install -m 644 data/*csv ${DESTDIR}/usr/share/spectacle/
	install -m 644 data/GROUPS ${DESTDIR}/usr/share/spectacle/

clean:
	rm -rf build/
	rm -f README.html
	cd spectacle/spec; $(MAKE) clean
	cd spectacle/dsc; $(MAKE) clean
