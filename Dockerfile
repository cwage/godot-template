# Headless Godot for exports/CI. The GUI editor is NOT this image's job —
# see the Makefile (`make edit`) for the pinned local editor binary.
FROM debian:bookworm-slim

# Single source of truth for the pinned Godot version and artifact checksums.
# The Makefile extracts these ARG defaults with sed — keep the `ARG NAME=value`
# format (no spaces, one per line). To bump: update the version, then refresh
# both checksums from
#   https://github.com/godotengine/godot/releases/download/<ver>-stable/SHA512-SUMS.txt
ARG GODOT_VERSION=4.6.3
ARG GODOT_ZIP_SHA512=a035258da32b77f966a5376f9fa29c30a6adde826a85ba918e1605bd1fc9823eba7d85f1dd5e748956bd2ba72827c0025ffa11bb82aec91128c407a2e723c99c
ARG TEMPLATES_TPZ_SHA512=da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl unzip zip && rm -rf /var/lib/apt/lists/*

# Engine binary (also the headless CLI)
RUN curl -fsSL -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
 && echo "${GODOT_ZIP_SHA512}  /tmp/godot.zip" | sha512sum -c - \
 && unzip -q /tmp/godot.zip -d /tmp \
 && mv "/tmp/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot \
 && chmod +x /usr/local/bin/godot \
 && rm /tmp/godot.zip

# Export templates: prebuilt runtime binaries that exported games are packed
# with. The .tpz bundles every platform (~1 GB); we keep only Linux to slim
# the image. To export for Windows/Web/etc., drop the matching pattern from
# the `rm` line below.
RUN curl -fsSL -o /tmp/templates.tpz "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz" \
 && echo "${TEMPLATES_TPZ_SHA512}  /tmp/templates.tpz" | sha512sum -c - \
 && mkdir -p "/usr/local/share/godot/export_templates/${GODOT_VERSION}.stable" \
 && unzip -q /tmp/templates.tpz -d /tmp \
 && rm -f /tmp/templates/android_* /tmp/templates/ios.zip /tmp/templates/macos.zip /tmp/templates/web_* /tmp/templates/windows_* \
 && mv /tmp/templates/* "/usr/local/share/godot/export_templates/${GODOT_VERSION}.stable/" \
 && chmod -R a+rX /usr/local/share/godot \
 && rm -rf /tmp/templates.tpz /tmp/templates

# Run as any UID (compose maps the host user): templates are read from
# XDG_DATA_HOME, transient config/cache goes to /tmp.
ENV XDG_DATA_HOME=/usr/local/share
ENV HOME=/tmp
ENV XDG_CONFIG_HOME=/tmp/.config
ENV XDG_CACHE_HOME=/tmp/.cache

WORKDIR /project
