# AGENTS.md

Guidance for AI coding agents working in this repo (useful for humans too). This is a
hermetic, multi-language Bazel monorepo generated from the Aspect Workflows starter template.

## Build, test, run
- Dev environment: `bazel run //tools:bazel_env` (with [direnv](https://direnv.net); `direnv allow`).
- Build / test: `bazel build //...` and `bazel test //...`.
- Lint / format: `aspect lint //...` and `aspect format`.
- Regenerate `BUILD` files after adding/moving code: `aspect gazelle`.

## Conventions & landmines
- **Gazelle owns most `BUILD` files** — don't hand-edit generated targets; change the source
  and re-run gazelle.
- **One Version Rule** — one resolved version per dependency per ecosystem. To deliberately
  diverge, add a *separate* hub/module, don't add a second version to the shared hub.
- **Dependency changes** = edit the manifest, then re-lock, then gazelle (e.g. Python
  `./tools/repin`; Go `go mod tidy` + `bazel mod tidy`; JS `pnpm add`; JVM `bazel run @maven//:pin`).
- **License headers are enforced** — run `bazel run //tools/license:add` before committing.

## Conventions
- **Conventional commits** (`feat:`, `fix:`, `chore:`, `docs:` …).
- Planning/design docs under `docs/` marked `status: completed` are done — don't treat them as
  open TODOs.
