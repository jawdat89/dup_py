# Dup_py — local documentation

Documentation for **Dup_py** (entry `src/dup_py.py`, engine `DupPyCore`). Upstream: [PJDude/dude](https://github.com/PJDude/dude).

| Document | Description |
|----------|-------------|
| [install.md](install.md) | Setup, launchers (GUI + `run-dup_py_cmd64.bat`), CLI/CSV, logging, layout |
| [architecture.md](architecture.md) | Layers, scan pipelines, logging, data structures, threading |
| [codebase-map.md](codebase-map.md) | **Source regions by file and line range** (`dup_py.py`, `core.py`, …) |
| [known-limitations.md](known-limitations.md) | Large-file I/O, one-scan scope, RAM/cache, UI notes |

## Recent local changes (2026-05)

| Area | What changed |
|------|----------------|
| **Large files** | SHA-1 always uses 1 MB chunks; CRC/image caches load via zstd `stream_reader` + `pickle.Unpickler` |
| **Remove duplicates** | `TkButton` on groups toolbar; enabled when files are marked and app is idle (same as Ctrl+Delete) |
| **Logging** | [loguru](https://github.com/Delgan/loguru) via `src/dup_py_log.py`; CLI `--debug`; logs in `dup_py.data/logs/` |
| **Launchers** | `run-dup_py.bat` / `run-dup_py64.bat` (GUI), `run-dup_py_cmd64.bat` (CLI/CSV); 64-bit `.venv` or `py -3-64`; `DUP_PY_LAUNCHER` in logs |
| **CLI / CSV** | Headless `--csv` mode fixed (`scan()` args, loguru progress); CSV written as UTF-8 |
| **64-bit guard** | `require_64bit_python()` at startup; `console.py` falls back to 64-bit `dup_py.py` when no `.exe` |
| **Mark one per group** | Toolbar button marks oldest file per duplicate group (like Ctrl+O) |
| **Portable data** | `dup_py.data` at repo root when running `src/dup_py.py` (not under `src/`) |
| **Rename** | User-facing name **Dup_py**; portable data folder **dup_py.data** (was `dude.data`) |
| **Image scan** | PIL `MAX_IMAGE_PIXELS` disabled for similarity/GPS scans (logged warning) |
| **Scan logs** | `scan walk done` / `crc_calc done` summary lines in log file |

## Source at a glance

| File | ~Lines | Role |
|------|--------|------|
| `src/dup_py.py` | 7500+ | Tkinter GUI, toolbar, marking, file actions, `__main__` |
| `src/core.py` | 1820 | Filesystem scan, SHA-1 / image hash, cache, delete & link (`DupPyCore`) |
| `src/dup_py_log.py` | ~90 | loguru setup + stdlib `logging` bridge |
| `src/console.py` | 120 | CLI (`--debug`, `--log`, …); Windows `dup_py_cmd` wrapper |
| `src/dialogs.py` | 530 | Reusable dialog windows |
| `src/text.py` | 2370 | Translations (`LANGUAGES` / `STR`) |
| `src/dup_py_images.py` | generated | Embedded toolbar/tree icons |

Start with [architecture.md](architecture.md) for behavior, then [codebase-map.md](codebase-map.md) when editing a specific region.
