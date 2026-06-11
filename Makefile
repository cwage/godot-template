# Single source of truth for the Godot version + checksums is the Dockerfile
# ARG defaults — extracted here so there's exactly one place to bump.
GODOT_VERSION := $(shell sed -n 's/^ARG GODOT_VERSION=//p' Dockerfile)
GODOT_ZIP_SHA512 := $(shell sed -n 's/^ARG GODOT_ZIP_SHA512=//p' Dockerfile)
GODOT_DIR := tools/godot-$(GODOT_VERSION)
GODOT_BIN := $(GODOT_DIR)/Godot_v$(GODOT_VERSION)-stable_linux.x86_64

.PHONY: edit build clean

# Launch the pinned editor (downloads it on first run). The GUI can't be
# usefully dockerized, so version-pinning the binary is the consistency story.
edit: $(GODOT_BIN)
	$(GODOT_BIN) --editor .

$(GODOT_BIN):
	mkdir -p $(GODOT_DIR)
	curl -fsSL -o $(GODOT_DIR)/godot.zip "https://github.com/godotengine/godot/releases/download/$(GODOT_VERSION)-stable/Godot_v$(GODOT_VERSION)-stable_linux.x86_64.zip"
	echo "$(GODOT_ZIP_SHA512)  $(GODOT_DIR)/godot.zip" | sha512sum -c -
	unzip -q $(GODOT_DIR)/godot.zip -d $(GODOT_DIR)
	rm $(GODOT_DIR)/godot.zip

# Container user for the export. Rootful docker: the invoking user, so bind
# mount output isn't root-owned. Rootless docker: container root, which the
# user namespace maps back to the host user (an unprivileged container UID
# would map to an unwritable subuid instead).
DOCKER_USER := $(if $(findstring rootless,$(shell docker info -f '{{.SecurityOptions}}' 2>/dev/null)),0:0,$(shell id -u):$(shell id -g))

# Dockerized release export — identical to what CI runs (CI calls this target).
build:
	DOCKER_USER=$(DOCKER_USER) docker compose run --rm export

clean:
	rm -rf builds
