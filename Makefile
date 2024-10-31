ROOT := $(PWD)
DOCKER_DIR := $(ROOT)/docker

DATA_DIR ?= $(ROOT)/data/
SCRIPT ?= $(ROOT)/example/hello_tf.py
SCRIPT_DIR := $(dir $(SCRIPT))
SCRIPT_NAME := $(notdir $(SCRIPT))
TAG ?= latest

BASE_DOCKER_URL := ghcr.io/davidrconnell
FILES := $(patsubst docker/%.Dockerfile,%,$(wildcard docker/*))

DOCKER_RUN = docker run --rm -ti \
	       --volume "$(DATA_DIR)":/data \
	       --volume "$(SCRIPT_DIR)":/script \
	       --volume "$(PWD)":/home/me \
	       --workdir /home/me \
	       --env SCRIPT="$(SCRIPT_NAME)" \
	       $(1)

publish_targets := $(patsubst %,_publish-%,$(FILES))
build_targets := $(patsubst %,build/%,$(FILES))
local_targets := $(patsubst %,local-%,$(FILES))

.PHONY: all
all: basenji_prespecified

.PHONY: $(FILES)
$(FILES):
	@[ -d $(DATA_DIR) ] || mkdir -p $(DATA_DIR)
	$(call DOCKER_RUN,$(BASE_DOCKER_URL)/$@:$(TAG))

.PHONY: $(local_targets)
$(local_targets): local-%: build/%
	@[ -d $(DATA_DIR) ] || mkdir -p $(DATA_DIR)
	$(call DOCKER_RUN,$*:$(TAG))

# "hidden" target. Should only be called by GitHub workflow.
.PHONY: _publish
_publish: $(publish_targets)

_publish-%: build/%
	docker push $(BASE_DOCKER_URL)/$*:$(TAG)

.PHONY: build
build: $(build_targets)

build/%: $(DOCKER_DIR)/%.Dockerfile .dockerignore
	@[ -d build ] || mkdir build
	docker build --tag $(BASE_DOCKER_URL)/$*:$(TAG) --file $< . && \
	touch $@

build/basenji_prespecified: etc/basenji/call_script.sh

.PHONY: clean
clean:
	rm -rf build

.PHONY: clean-dist
clean-dist: clean
	rm -rf data && mkdir data
	echo $(patsubst %,%,$(FILES)) | \
	  xargs -n1 docker images --quiet | \
	  xargs docker rmi
