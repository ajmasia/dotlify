# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.0] — 2026-04-30

### Added
- `lib/theme.sh`: Catppuccin Mocha palette as 24-bit truecolor escapes; semantic role helpers (`theme::accent`, `theme::text`, `theme::subtext`, `theme::success`, `theme::warning`, `theme::error`, `theme::info`, `theme::reset`); `theme::supports_color` with `THEME_COLORS_ENABLED` flag; honors `NO_COLOR` and `DOTS_NO_COLOR`.
- `lib/ui.sh`: typed-prefix message printers (`ui::info`, `ui::warn`, `ui::error`, `ui::step`, `ui::ok`) with semantic color on prefix and Mocha Text on body; `ui::banner` with Figlet + Mauve color and plain-text fallback.
- `tests/lib/theme.bats`: color emission, `NO_COLOR`, `DOTS_NO_COLOR`, non-TTY tests.
- `tests/lib/ui.bats`: prefix format, stderr routing, color vs no-color, banner fallback tests.
- Makefile `test` target now uses `bats --recursive` to cover subdirectories.

## [0.1.0] — 2026-04-30

### Added
- Repository skeleton: `bin/`, `lib/`, `tests/`, `completions/`, `examples/`, `profiles/` directories.
- `lib/version.sh` exporting `OPENDOTS_VERSION="0.1.0"`.
- `Makefile` with `lint`, `fmt`, `fmt-check`, `test`, `check` targets.
- `.editorconfig` and `.gitattributes` enforcing LF and 2-space indentation on shell files.
- `tests/test_helper.bash` with temp-`$HOME` / temp-`DOTS_DIR` helpers.
- `tests/00_smoke.bats` placeholder smoke test.
- `.githooks/pre-commit` running `make check`.
- GitHub Actions CI matrix (`ubuntu-latest`, `macos-latest`).
- `README.md` skeleton with usage, installation, and development instructions.
