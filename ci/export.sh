#!/bin/sh
# Export a release build for the given preset (see export_presets.cfg).
# Used by both `docker compose run --rm export` and GitHub Actions, so
# local builds and CI stay identical.
set -eu

PRESET="${1:-Linux}"

mkdir -p builds/linux

# First pass imports assets into .godot/ (required on a fresh checkout),
# second pass does the actual export.
godot --headless --import
godot --headless --export-release "$PRESET"

echo "Exported preset '$PRESET':"
ls -lh builds/linux/
