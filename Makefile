ROOT := $(PWD)
DOCKER_DIR := $(ROOT)/docker

DATA_DIR ?= $(ROOT)/data/
SCRIPT ?= $(ROOT)/example/hello_tox.py
SCRIPT_DIR := $(dir $(SCRIPT))
SCRIPT_NAME := $(notdir $(SCRIPT))
TAG ?= latest

BASE_DOCKER_URL := "ghcr.io/davidrconnell"
FILES := $(patsubst docker/%.Dockerfile,%,$(wildcard docker/*))

DOCKER_RUN = docker run --rm -ti \
	       -v "$(DATA_DIR)":/data \
	       -v "$(SCRIPT_DIR)":/script \
	       -v "$(PWD)":/home/$* \
	       -w /home/$* \
	       -e SCRIPT="$(SCRIPT_NAME)" \
	       $(1)

publish_targets := $(patsubst %,_publish-%,$(FILES))
build_targets := $(patsubst %,build-%,$(FILES))
local_targets := $(patsubst %,local-%,$(FILES))

.PHONY: all
all: basenji

.PHONY: $(FILES)
$(FILES):
	$(call DOCKER_RUN,$(BASE_DOCKER_URL)/$@:$(TAG))

.PHONY: $(local_targets)
$(local_targets): local-%: build/%
	$(call DOCKER_RUN,localhost/$*:$(TAG))

# "hidden" target. Should only be called by GitHub workflow.
.PHONY: _publish
_publish: $(publish_targets)

.PHONY: $(publish_targets)
_publish-%: build/%
	docker push $(BASE_DOCKER_URL)/$*:$(TAG)

.PHONY: build
build: $(build_targets)

build/%: $(DOCKER_DIR)/%.Dockerfile
	[ -d build ] || mkdir build
	docker build --tag $*:$(TAG) --file $< . && touch $@

.PHONY: clean
clean:
	rm -rf build

.PHONY: clean-dist
clean-dist: clean
	rm -rf data && mkdir data
	echo $(patsubst %,localhost/%,$(FILES)) | \
	  xargs -n1 docker images --quiet | \
	  xargs docker rmi
