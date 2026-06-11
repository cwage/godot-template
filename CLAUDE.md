# godot-playground

Godot 4.6.3 learning project. GDScript, single Linux export preset, dockerized builds.

## Commands

- `make build` — dockerized release export via `docker compose run --rm export`; output in `builds/linux/`. This is exactly what CI runs (`ci/export.sh` is the shared entry point).
- `make edit` — fetches the pinned editor binary into `tools/` and opens the GUI editor. Blocking GUI app: never run it from an agent session; ask the user to run it.
- Headless smoke test of an export: `./builds/linux/godot-playground.x86_64 --headless --quit`

## Conventions

- Scenes in `scenes/` (`.tscn`), scripts in `scripts/` (`.gd`) — all plain text, safe to edit directly.
- Commit `.uid` sidecar files (e.g. `scripts/main.gd.uid`); never commit `.godot/`, `tools/`, or `builds/`.
- GDScript uses tabs (see `.editorconfig`).
- The Godot version and artifact checksums are pinned in exactly one place: the `ARG` defaults at the top of the `Dockerfile`. The Makefile sed-extracts them, so the `ARG NAME=value` line format must be preserved. (`config/features` in `project.godot` looks like a pin but is an editor-managed minor-version feature tag — leave it alone.)
- Adding an export platform: keep its templates in the `Dockerfile` (remove from the `rm` line), add a preset via the editor (writes `export_presets.cfg`), wire it into `ci/export.sh` callers.

## Releases

Tag `v*` and push — `.github/workflows/build.yml` exports and attaches the binary to a GitHub Release.
