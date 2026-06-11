# godot-playground

A starter template for learning [Godot](https://godotengine.org/) (MIT-licensed,
free, no royalties), pinned to an exact Godot version with dockerized builds
and a tag-based release pipeline.

The version pin and artifact checksums live in **one place**: the `ARG`
defaults at the top of the `Dockerfile`. The Makefile extracts them from
there. To upgrade Godot, edit the version there and refresh both checksums
from the release's `SHA512-SUMS.txt`, e.g.
`https://github.com/godotengine/godot/releases/download/4.6.3-stable/SHA512-SUMS.txt`.

## How Godot fits together

- The Godot download is a single self-contained binary that is **both** the GUI
  editor and a headless CLI (`godot --headless ...`).
- GDScript (`.gd`) is not compiled to native code — it runs as interpreted
  bytecode inside the engine, which is C++ underneath.
- "Exporting" a game = packing your scripts/scenes/assets into a `.pck` and
  combining it with a prebuilt per-platform engine binary (an *export
  template*). No compiler toolchain involved, so builds are fast and
  reproducible — and easy to dockerize.

## Layout

| Path | What |
|---|---|
| `project.godot` | Project config (the thing the editor opens) |
| `scenes/` | Scene files (`.tscn`, plain text) |
| `scripts/` | GDScript (`.gd`, plain text) |
| `export_presets.cfg` | Export targets; currently one Linux x86_64 preset |
| `Dockerfile` / `compose.yaml` | Headless Godot + Linux export templates, checksum-verified |
| `ci/export.sh` | The export step — shared verbatim by local builds and CI |
| `.github/workflows/build.yml` | Builds on push/PR; attaches binaries to GitHub Releases on `v*` tags |
| `Makefile` | `make edit`, `make build`, `make clean` |

## Editing

```
make edit
```

Downloads the pinned, checksum-verified editor binary into `tools/`
(gitignored) on first run, then opens the project. The GUI editor needs a real
display + GPU, so it runs natively rather than in docker — version pinning is
what keeps machines consistent.

Run the game from the editor with **F5**.

The editor generates two kinds of files: `.godot/` (import cache — gitignored,
never commit) and `*.uid` sidecars next to scripts (stable resource IDs —
**always commit these**).

### Using your own editor for code

`.gd`/`.tscn` files are plain text — edit them with anything. For IDE support,
the Godot editor runs an LSP server while open (port 6005): install the
**godot-tools** extension (VS Code) or equivalent, and optionally set
*Editor Settings → Text Editor → External* so script clicks open your editor.
You'll still use the Godot editor for scene composition.

## Building (dockerized)

```
make build
```

This wraps `docker compose run --rm export`, setting the container user to
match your environment: your own UID on rootful docker (so output isn't
root-owned), container root on rootless docker (where the user namespace maps
it back to you). If you invoke compose directly on a rootless setup, set
`DOCKER_USER=0:0`.

First run builds the image (downloads ~1 GB of export templates once, then
cached). Output lands in `builds/linux/godot-playground.x86_64` — a single
self-contained executable (the `.pck` is embedded).

CI runs the exact same image and script, so a green local build means a green
remote build.

## Releasing

Tag and push:

```
git tag v0.1.0 && git push origin v0.1.0
```

The workflow exports the game and attaches the binary to a GitHub Release for
that tag.

## Adding export platforms (Windows, Web, …)

1. Keep the relevant templates in the image: remove the matching pattern from
   the `rm` line in the `Dockerfile`.
2. Add a preset in the editor (*Project → Export…*) — it writes
   `export_presets.cfg`, which is committed. (Don't commit it if you later add
   Android keystore passwords to it.)
3. Call `ci/export.sh <PresetName>` for the new preset in `compose.yaml`/CI.

## Learning path

- [Official Getting Started guide](https://docs.godotengine.org/en/stable/getting_started/introduction/index.html)
  — core concepts: everything is a tree of **nodes**, reusable subtrees are
  **scenes**.
- [Your first 2D game](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html)
  ("Dodge the Creeps") — the canonical first project.
- [GDScript reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
