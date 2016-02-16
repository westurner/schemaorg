
## Schema.org Course Extension Makefile

default: test

PYTHON=$(shell which python)
test:
	$(PYTHON) _build.py

test-course-rdfa:
	rdfpipe -i rdfa1.1 -o turtle ./course.rdfa.html5.html
