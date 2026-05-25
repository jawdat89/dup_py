# Install and run

**Dup_py** — fork of DUDE; window title and about dialog use that name. Runtime data: **`dup_py.data`** (rename an existing `dude.data` folder if you want to keep cache/config).

## Quick start (Windows)

From the repository root:

```bat
run-dup_py.bat
```

**64-bit Python (recommended)** — uses the project venv so all dependencies (including `tkinterdnd2`) are available:

```bat
run-dup_py64.bat
```

| Launcher | Python used |
|----------|-------------|
| `run-dup_py.bat` | `.venv\Scripts\python.exe` |
| `run-dup_py64.bat` | `.venv` if 64-bit, else `py -3-64` (warns if venv deps missing) |

Or directly:

```bat
.\.venv\Scripts\python.exe src\dup_py.py
```

## First-time setup

```bat
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
.\scripts\icons.convert.bat
.\scripts\version.gen.bat
```

`requirements.txt` includes **loguru** for structured logging.

## Logging

Logging is configured in `src/dup_py_log.py`:

- **File:** timestamped log under `dup_py.data/logs/` (or `-l path`)
- **Console:** colorized stderr (same levels as file)
- **Engine:** `DupPyCore` still uses stdlib `logging`; records are forwarded to loguru

```bat
run-dup_py64.bat --debug
run-dup_py64.bat -l C:\temp\my-run.log --debug
```

Useful log lines after a scan:

- `Logging initialized` — Python version, bitness, launcher (`DUP_PY_LAUNCHER`)
- `scan walk done` — files seen, duplicate size buckets
- `crc_calc done` — files hashed vs total
- `remove_duplicates_button state=…` — with `--debug` when marking files

## CLI examples

```bat
run-dup_py64.bat .
run-dup_py64.bat C:\folder1 D:\folder2
run-dup_py64.bat --help
run-dup_py64.bat --norun
run-dup_py64.bat --csv report.csv C:\folder --exclude "*.git/*"
```

| Flag | Purpose |
|------|---------|
| `--debug` | DEBUG level to console and log file |
| `-l LOG` | Custom log file path |
| `-ad` / `--appdirs` | Use platform app-data instead of portable `dup_py.data` |

## Remove duplicates (toolbar)

After a scan:

1. In the **lower folder** panel, select a duplicate **file** (not only the group header).
2. Press **Space** to toggle mark (or use marking menus).
3. Click **Remove duplicates** above the groups list (enabled when count of marked files > 0).

Same action as **Ctrl+Delete** or context menu **Remove Marked Files …** (all marked files, with confirmations).

## Runtime data

Logs, config, and cache default to `dup_py.data` next to the script, or platform app-data folders when that directory is not writable (`--appdirs`).

## Layout

| Path | Purpose |
|------|---------|
| `src/dup_py.py` | Main GUI entry |
| `src/core.py` | Scanning, hashing, cache |
| `src/dup_py_log.py` | loguru + logging bridge |
| `src/console.py` | Argument parsing |
| `.venv/` | Local Python environment (not committed) |
| `run-dup_py.bat` | Launcher (venv) |
| `run-dup_py64.bat` | Launcher (64-bit venv preferred) |
| `dup_py.data/` | Runtime logs, `cfg.ini`, cache (created at run time) |

## Updating from upstream

```bat
git pull
.\.venv\Scripts\pip install -r requirements.txt
.\scripts\icons.convert.bat
.\scripts\version.gen.bat
```

## See also

[known-limitations.md](known-limitations.md) — large-file I/O, what “one scan” includes, cache RAM limits.
