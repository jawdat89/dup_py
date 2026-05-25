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

| Launcher | Use |
|----------|-----|
| `run-dup_py.bat` / `run-dup_py64.bat` | GUI (64-bit `.venv` or `py -3-64`) |
| `run-dup_py_cmd64.bat` | CLI / CSV mode (same 64-bit rules) |

All launchers require **64-bit Python**. A direct `python src\dup_py.py` call on 32-bit Python exits with an error.

Or directly:

```bat
.\.venv\Scripts\python.exe src\dup_py.py
```

## First-time setup

Use **64-bit** Python for the venv:

```bat
py -3-64 -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
.\scripts\icons.convert.bat
.\scripts\version.gen.bat
```

`requirements.txt` includes **loguru** for structured logging.

## Logging

Logging is configured in `src/dup_py_log.py`:

- **File:** timestamped log under `dup_py.data/logs/` (gitignored; next to the app or repo root when running `src/dup_py.py`)
- **CLI `-l path`:** optional override for that run
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

Use **`run-dup_py_cmd64.bat`** (or `run-dup_py64.bat`) so scans run on 64-bit Python:

```bat
run-dup_py_cmd64.bat .
run-dup_py_cmd64.bat C:\folder1 D:\folder2
run-dup_py_cmd64.bat --help
run-dup_py_cmd64.bat --csv report.csv C:\folder --exclude "*.git/*"
run-dup_py_cmd64.bat --debug --csv report.csv "D:\My Photos"
```

| Flag | Purpose |
|------|---------|
| `--debug` | DEBUG level to console and log file |
| `-l LOG` | Custom log file path |
| `-ad` / `--appdirs` | Use platform app-data instead of portable `dup_py.data` |
| `-c` / `--csv FILE` | Headless scan; write duplicate groups to CSV (UTF-8 paths) |

### Example: scan a folder to CSV

```bat
run-dup_py_cmd64.bat --debug --csv dup_py.data\my_scan.csv "D:\Photos\Vacation"
```

Output:

- **CSV:** `dup_py.data\my_scan.csv` — groups as `size,crc` rows plus file paths
- **Log:** `dup_py.data\logs\YYYY_MM_DD_HH_MM_SS.txt`
- **Cache:** `dup_py.data\cache-<version>\<hostname>\` (speeds up re-scans)

## Mark one per group (toolbar)

After a scan, click **Mark one per group** (enabled whenever groups are shown) to clear marks and mark the **oldest** file in each duplicate group — same as **Mark Oldest files** (Ctrl+O). Then use **Remove duplicates** or other actions.

## Remove duplicates (toolbar)

After a scan:

1. In the **lower folder** panel, select a duplicate **file** (not only the group header).
2. Press **Space** to toggle mark (or use marking menus).
3. Click **Remove duplicates** above the groups list (enabled when count of marked files > 0).

Same action as **Ctrl+Delete** or context menu **Remove Marked Files …** (all marked files, with confirmations).

## Runtime data

Logs, config, and cache live in **`dup_py.data`** at the repository root when you run `src\dup_py.py` from a clone (folder is **gitignored**). Packaged builds use `dup_py.data` next to the executable. Use `--appdirs` if the portable folder is not writable.

## Layout

| Path | Purpose |
|------|---------|
| `src/dup_py.py` | Main GUI entry |
| `src/core.py` | Scanning, hashing, cache |
| `src/dup_py_log.py` | loguru + logging bridge |
| `src/console.py` | Argument parsing |
| `.venv/` | Local Python environment (not committed) |
| `run-dup_py.bat` | GUI launcher (64-bit) |
| `run-dup_py64.bat` | GUI launcher (64-bit, explicit name) |
| `run-dup_py_cmd64.bat` | CLI / CSV launcher (64-bit) |
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
