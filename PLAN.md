# cc-nim Homebrew Integration & CLI Implementation Plan

## Objective
Add Homebrew formula and CLI commands (`init`, `start`, `stop`) to manage cc-nim server lifecycle and configuration on macOS/Linux.

## Scope
- Add `typer` as a dependency for consistent CLI exit handling.
- Implement CLI command functions in `cc_nim/cli.py` with proper error reporting and exit codes.
- Manage configuration via `~/.ccenv` with `CCPROXY_CONFIG` override.
- Use PID file `~/.cc-nim/cc-nim.pid` for start/stop coordination.
- Provide `brew services` integration for stop command (fallback to PID kill).
- Write comprehensive unit tests covering all commands and edge cases.
- Update documentation (`README.md`) and `run.sh` (deprecation notice).
- Create Homebrew formula `Formula/cc-proxy.rb`.

## Implementation Notes
- **Config Path Resolution**: Priority order: `CCPROXY_CONFIG` > `~/.ccenv` > `cwd/.env`. `_get_config_path()` handles this.
- **PID Handling**: `start_command` checks for existing PID; if process is running, exits with error; if stale, removes PID and continues. Writes current PID on start; `stop_command` removes PID on exit.
- **Error Handling**: CLI commands raise `typer.Exit(code)` on failures to match test expectations.
- **Testing**: Tests located under `tests/cli/` use `pytest` with monkeypatching for isolation.

## Task List

| ID | Task | Status | Notes |
|----|------|--------|-------|
| 1 | Fork repository to `rainbow` org and create `feature/homebrew-setup` branch. | ⏳ Pending | |
| 2 | Update `pyproject.toml`: add `typer` dependency; ensure `[project.scripts]` entry point. | ✅ Completed | `typer>=0.9.0` added |
| 3 | Implement `init_command` (create config template). | ✅ Completed | |
| 4 | Implement `start_command` with PID check and `uvicorn.run`. | ✅ Completed | Includes stale PID handling |
| 5 | Implement `stop_command` with brew service first, PID fallback. | ✅ Completed | Brew stop tried; PID kill if needed |
| 6 | Write unit tests for CLI commands (`tests/cli/test_cli_commands.py`). | ✅ Completed | Covers success and error paths |
| 7 | Fix async test fixtures (`tests/conftest.py`) to use `AsyncMock`. | ✅ Completed | Resolved `MagicMock` await errors |
| 8 | Update `README.md` with Homebrew installation and usage. | ✅ Completed | Homebrew install and service usage documented |
| 9 | Create Homebrew formula `Formula/cc-proxy.rb`. | ✅ Completed | Formula added with service + post_install init |
| 10 | Update `run.sh` to show deprecation notice and direct to `cc-nim`. | ✅ Completed | Deprecation note present |
| 11 | Run full test suite (`uv run pytest`) and fix any failures. | ✅ Completed | 864 passed |
| 12 | Run lint/type checks (`ruff format`, `ruff check`, `ty`). | ✅ Completed | All checks passing |
| 13 | Commit changes and push to fork branch. | ✅ Completed | Pushed `codex/homebrew-stabilization` to `rainbow` |
| 14 | Create pull request to upstream repository. | ⏸ Deferred | Explicitly skipped per user instruction (do not PR to origin) |
| 15 | Revert fork-specific URLs/branches to upstream defaults before upstream PR (README testing snippet + `Formula/cc-proxy.rb` homepage/url/head). | ⏳ Pending | Required cleanup before opening PR to origin |
| 16 | Fix broken `rainbow-365/tap` formula metadata and validate Homebrew install/test end-to-end. | ✅ Completed | `brew test rainbow-365/tap/cc-proxy` passing |

## Completed Code Changes
- Added `import typer` to `cc_nim/cli.py`.
- Changed all CLI error returns to `raise typer.Exit(1)`.
- Added PID existence and liveness check in `start_command`.
- Modified tests to expect `typer.Exit` and fixed stale PID mock to use `ProcessLookupError`.
- Updated `tests/conftest.py` to use `AsyncMock` for async methods.
- Hardened `Formula/cc-proxy.rb` for Homebrew compatibility:
  - added explicit `version`
  - switched install flow to `python -m pip --python=<venv> install` to ensure runtime deps (including `typer`) are installed
  - made `post_install` deterministic with `CCPROXY_CONFIG=~/.ccenv` and safe no-op when config exists
- Validated tap packaging behavior with clean install/test cycle:
  - `brew install --build-from-source rainbow-365/tap/cc-proxy`
  - `brew test rainbow-365/tap/cc-proxy` (pass)
  - packaged `cc-nim` smoke checks (usage + `init` with temp config path)

## Next Steps
1. Keep fork-specific formula/README settings for branch testing; when preparing upstream PR, revert to upstream/origin URLs and default branch refs.
2. Replace commit-pinned formula `url` with release tag strategy before external distribution.
3. If upstream PR is needed later, open it only after user explicitly approves.

---
*Last updated: 2026-03-03*
