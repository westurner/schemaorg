
### Schema.org Makefile

default: test

help:
	@echo ''

.PHONY:	default \
	generate_PHONY \
	install \
	appenginesdk_open_download_url \
	appenginesdk_install \
	appenginesdk_download_zip \
	appenginesdk_unzip \
	dev_appserver \
	run \
	install_pip \
	install_requirements \
	install_requirements_tests \
	clone_schemaorg \
	test \
	testext-course \
	build-docker \
	run-docker-interactive \
	run-docker-background


generate_PHONY:
	@# generate a .PHONY block of all targets in ./Makefile
	@cat ./Makefile \
		| pyline -r '^([\w\-_]+)\s*:(\s|\n)' 'rgx and rgx.group(1)' \
		| tr '\n' ' ' \
		| pyline -m textwrap \
		'(".PHONY:\t") + ("\n".join( \
			["\t{} \\".format(x) for x in words]) \
			.lstrip("\t").rstrip(" \\"))'
		@# | pbcopy

install:
	$(MAKE) appenginesdk_install
	$(MAKE) pip

appenginesdk_open_download_url:
	python -m webbrowser 'https://cloud.google.com/appengine/downloads#Google_App_Engine_SDK_for_Python'

appenginesdk_open_docs_url:
	python -m webbrowser -t 'https://cloud.google.com/appengine/docs/'
	python -m webbrowser -t 'https://cloud.google.com/appengine/docs/python/'

appenginesdk_install:
	$(MAKE) appenginesdk_open_download_url
	$(MAKE) appenginesdk_download_zip
	$(MAKE) appenginesdk_unzip

## appengine installed in /usr/local/google_appengine
#APPENGINESDK_BASEPATH:=/usr/local

## appengine installed in e.g. ~/google-cloud-sdk/platform/google_appengine
GCLOUD_BASEPATH:=$(HOME)
APPENGINESDK_BASEPATH:=$(GCLOUD_BASEPATH)/google-cloud-sdk/platform

APPENGINESDK_VERSION:=1.9.32
APPENGINESDK_ARCHIVE:=google_appengine_$(APPENGINESDK_VERSION).zip
APPENGINESDK_ARCHIVE_URL:=https://storage.googleapis.com/appengine-sdks/featured/$(APPENGINESDK_ARCHIVE)
appenginesdk_download_zip:
	#curl -S --continue - -O '$(APPENGINESDK_ARCHIVE_URL)'
	test  -f '$(APPENGINESDK_ARCHIVE)' \
		|| (which wget && wget -q --continue '$(APPENGINESDK_ARCHIVE_URL)') \
		|| (which curl && curl -f -s -S -O '$(APPENGINESDK_ARCHIVE_URL)')

appenginesdk_unzip:
	test -f '$(APPENGINESDK_ARCHIVE)'
	test -d '$(APPENGINESDK_BASEPATH)' || \
		mkdir -p '$(APPENGINESDK_BASEPATH)'
	unzip '$(APPENGINESDK_ARCHIVE)' -d '$(APPENGINESDK_BASEPATH)'

APPENGINESDK_PATH=$(APPENGINESDK_BASEPATH)/google_appengine
DEV_APPSERVER=$(APPENGINESDK_PATH)/dev_appserver.py
dev_appserver:
	$(DEV_APPSERVER) --automatic_restart True .

run: dev_appserver


##
PYTHON:=$(shell which python)
PYTHONPATH=/usr/local/google_appengine

install_pip:
	test -f get-pip.py \
		|| (which wget \
		&& wget --continue https://bootstrap.pypa.io/get-pip.py) \
		|| (which curl \
		&& curl -s -S -O https://bootstrap.pypa.io/get-pip.py)
	$(PYTHON) ./get-pip.py

install_requirements:
	$(PYTHON) -m pip install -r requirements.txt

install_requirements_tests:
	$(PYTHON) -m pip install -r ./requirements-test-extra.txt

GITURL='https://github.com/schemaorg/schemaorg'
GITREV='sdo-deimos'

GITURL='https://github.com/westurner/schemaorg'
GITREV='feature/ext-course'

clone_schemaorg:
	git clone $(GITURL) -b $(GITREV)


## schemaorg Makefile
test:
	@# python ./scripts/run_tests.py
	PYTHONPATH=$(PYTHONPATH) $(PYTHON) ./scripts/run_tests.py
	$(MAKE) testext-course

testext-course:
	PYTHONPATH=$(PYTHONPATH) \
		$(MAKE) -C ./data/ext/course test

## Docker

REPOTAG='schemaorg/appengine-ubuntu-15.04'
DOCKER_ENV=--env GITURL=$(GITURL) --env GITREV=$(GITREV)
DOCKER_ARG=--build-arg GITURL=$(GITURL) \
		   --build-arg GITREV=$(GITREV)
#DOCKEROPTS=
build-docker:
	docker build -f Dockerfile.ubuntu-15.04 -t $(REPOTAG) \
		$(DOCKER_ARG) \
		.

run-docker-interactive:
	docker run -i -t $(DOCKER_ENV) $(REPOTAG) /bin/bash.

run-docker-background:
	docker run -t $(DOCKER_ENV) $(REPOTAG)

