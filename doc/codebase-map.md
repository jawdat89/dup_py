# Codebase map

Exact module layout and **line regions** in the main source files (line numbers refer to `src/` as of the local tree; small drift is normal after upstream edits).

## Repository layout

```
C:\Dev\utilities\dude\
├── doc/                    # Local documentation (this folder)
├── scripts/                # Build: icons, version, PyInstaller, Nuitka
├── src/                    # All application Python source
│   ├── dup_py.py             # GUI + entry point (~7.4k lines)
│   ├── core.py             # Scan engine (~1.8k lines)
│   ├── console.py          # CLI / dup_py_cmd wrapper
│   ├── dialogs.py          # Tk dialog widgets
│   ├── text.py             # i18n strings (LANGUAGES)
│   ├── dup_py_images.py      # Generated embedded PNG icons (build artifact)
│   ├── version.py          # Version file generator (build)
│   ├── png.2.py.py         # Icon → dup_py_images.py converter
│   ├── dup_py_log.py         # loguru setup + logging bridge
│   ├── hook-tkinterdnd2.py # PyInstaller hook
│   └── test.py             # Synthetic tree generator (core self-test)
├── requirements.txt        # includes loguru
├── run-dup_py.bat            # Launcher → .venv
├── run-dup_py64.bat          # Launcher → 64-bit .venv (preferred)
└── README.md               # Upstream readme
```

## `src/core.py` — engine (~1820 lines)

| Lines (approx.) | Symbol / region | Responsibility |
|-----------------|-----------------|----------------|
| 29–66 | imports, `DELETE`/`SOFTLINK`/… | Lazy imports; action kind constants |
| 68 | `IMAGES_EXTENSIONS` | Whitelist for image scan mode |
| 70–109 | `localtime_catched`, `bytes_to_str`, `str_to_bytes`, `fnumber` | Time/size formatting helpers |
| 108–123 | `_load_zstd_pickle_file` | zstd `stream_reader` + `pickle.Unpickler`; `MemoryError` handling |
| 127–205 | **`CRCThreadedCalc`** | Per-device SHA-1 thread; always 1 MB chunked hash |
| 201–207 | `is_hidden_win` / `is_hidden_lin` | Platform hidden-file detection |
| 209–211 | `MODE_CRC`, `MODE_SIMILARITY`, `MODE_GPS` | Scan operation modes |
| 213–237 | **`DupPyCore.__init__`**, `reset` | Cache dir, logging, empty result pools |
| 239–291 | path/exclude setup | `get_full_path_*`, `set_paths_to_scan`, `set_exclude_masks` |
| 296–343 | `abort`, `get_gps_data` | Cancel scan; EXIF GPS parsing |
| 346–665 | **`DupPyCore.scan`** | Directory walk; size buckets; PIL `MAX_IMAGE_PIXELS` off in image modes; scan summary log |
| 659–675 | `crc_cache_read` | Load per-device `.dat` cache (zstd + pickle) |
| 676–700 | `crc_cache_write` | Persist CRC cache |
| 702–735 | `images_data_cache_read/write` | Image hash cache file |
| 737–816 | `images_processing_in_thread` | PIL + imagehash per file (rotations optional) |
| 818–989 | `images_processing` | Thread pool; fill `scan_results_images_hashes` |
| 990–1065 | `similarity_clustering` | DBSCAN on hash vectors → `files_of_images_groups` |
| 1066–1117 | `gps_clustering` | Group by GPS distance |
| 1118–1373 | **`crc_calc`** | Cache reuse, ordering by folder/size, thread pool, build `files_of_size_of_crc` |
| 1375–1452 | `check_group_files_state` | Pre-action consistency (ctime check) |
| 1453–1467 | `write_csv` | Headless export |
| 1469–1496 | pool prune helpers | Remove singleton groups |
| 1498–1565 | `rename_file`, `delete_*`, `do_*_link` | Low-level filesystem ops |
| 1567–1744 | `remove_from_data_pool`, `hide_group_core`, `delete_file_wrapper`, `link_wrapper` | Group mutations after user actions |
| 1754–1798 | `__main__` | Dev test harness using `test.generate` |

## `src/dup_py.py` — GUI + main (~7449 lines)

| Lines (approx.) | Symbol / region | Responsibility |
|-----------------|-----------------|----------------|
| 29–96 | imports | Tkinter, `core.*`, `console`, `dialogs`, `text`, `dup_py_images` |
| 99–195 | `CFG_*` constants | Config keys for `cfg.ini` |
| 196–217 | `get_dev_labes_dict` | Drive label map (Windows volumes) |
| 219–283 | **`Config`** | Read/write `cfg.ini` sections |
| 285–295 | `measure` | Debug timing decorator |
| 297–456 | **`Image_Cache`** | Preview image cache + read-ahead thread pools |
| 458–604 | **`Gui` class header** | `MAX_PATHS=8`, decorators (`block`, `logwrapper`, …) |
| 605–1723 | **`Gui.__init__`** | Main window, preview window, scan dialog widgets, trees, menus, themes, drag-drop |
| 1724–1830 | scan menu helpers | Recent paths, device menu, size/mode toggles |
| 1837–1870 | drop handlers | `main_drop`, `scan_dialog_drop` |
| 1871–2350 | dialog factories | Settings, about, license, progress, mark, find, exclude |
| 2388–2710 | tree focus/tooltip | Groups/folder tree events, adaptive tooltips |
| 2711–3247 | status, find, keyboard | `status_main`, find next/prev, **`key_press`** / `key_release` shortcuts |
| 3248–3396 | navigation | CRC/folder goto, tree selection |
| 3397–3683 | **preview** | `show_preview`, `update_preview`, image/PDF/text, read-ahead |
| 3684–4057 | selection + context menus | `groups_tree_sel_change`, `folder_tree_sel_change`, `context_menu_show` |
| 4058–4186 | scan dialog actions | Add/remove paths, excludes, sort columns |
| 4187–4716 | **`Gui.scan`** | Orchestrate engine scan + hash + image pipelines + progress UI |
| 4717–4814 | scan dialog UI | Show/hide dialog, path list updates |
| 4815–4928 | settings | `settings_ok`, `settings_reset` |
| 4929–5101 | callbacks + `data_precalc` | Tree refresh hooks after file removal |
| 5102–5277 | **`groups_show`** | Populate upper groups tree from `files_of_size_of_crc` or image groups |
| 5278–5528 | tree updates | `groups_tree_update`, `tree_folder_update`, marks display |
| 5529–5670 | **marking** | By ctime, size, CRC group, folder, regexp, subpath |
| 5671–6030 | mark navigation / hide | `goto_next_mark`, `hide_group` |
| 6031–6755 | **process files** | Confirmations, trash/delete/link, `process_files_core` |
| 6756–7248 | utilities | CSV save, cache clean, clipboard, open file/folder, logs |
| 7249–7260 | `show_homepage` | Open project URL |
| 7261–7510 | **`__main__`** | `setup_logging`, `DupPyCore` init, CSV mode or `Gui()` |

### `Gui` functional regions (quick index)

Use these when jumping inside the 7k-line file:

1. **Construction** — 605–1723 (widgets, `groups_toolbar`, Remove duplicates button, layout, bindings)
2. **Dialogs** — 1871–2350
3. **Input / shortcuts** — 3025–3247
4. **Preview** — 3397–3683
5. **Scan orchestration** — 4187–4716
6. **Results UI** — 5102–5528
7. **Marking** — 5529–6030
8. **Remove duplicates button** — 5564–5590 (`update_remove_duplicates_button_state`, wrapper)
9. **Destructive actions** — 6031–6755

## `src/dup_py_log.py` (~90 lines)

| Symbol | Responsibility |
|--------|----------------|
| `_InterceptHandler` | Forward stdlib `logging` records to loguru |
| `setup_logging` | stderr + rotating file sinks; log Python bitness, launcher |
| `get_logger` | Optional `logger.bind(component=…)` (optional use) |

## `src/console.py` (~120 lines)

| Lines | Region | Responsibility |
|-------|--------|----------------|
| 39–45 | `get_ver_timestamp` | Read `version.txt` |
| 47–84 | `parse_args` | CLI flags (`--csv`, `--debug`, `--log`, `--exclude`, image modes, sizes) |
| 86–146 | `__main__` | Windows: forward argv to `dup_py.exe` via `start` |

## `src/dialogs.py` (~531 lines)

| Class | Purpose |
|-------|---------|
| `GenericDialog` | Base Toplevel: buttons, show/hide, parent lock |
| `LabelDialog` / `LabelDialogQuestion` | Simple message / yes-no |
| `ProgressDialog` | Scan progress bars + abort |
| `TextDialogInfo` / `TextDialogQuestion` | Scrollable text |
| `EntryDialogQuestion` / `CheckboxEntryDialogQuestion` | Text input prompts |
| `FindEntryDialog` | Find in tree |
| `SFrame` | Scrollable frame helper |

## `src/text.py` (~2345 lines)

| Region | Responsibility |
|--------|----------------|
| `LANGUAGES` class | `STR_DICT` keyed by English source string → locale; `STR()` lookup using `cfg` language |

All user-visible menu/tooltip strings go through `STR('...')` in `dup_py.py`.

## `src/dup_py_images.py` (~78 lines generated)

Embedded `dude_image["icon_name"] = b'...'` PNG bytes. Regenerated by `scripts/icons.convert.*` — **do not hand-edit**.

## `src/test.py` (~47 lines)

`generate()` builds random directory trees under `./test/files` for `core.py` `__main__` regression.

## Runtime directories (not in git)

| Path | Created by |
|------|------------|
| `dup_py.data/cfg.ini` | `Config` |
| `dup_py.data/logs/*.txt` | loguru via `setup_logging` in `__main__` |
| `dup_py.data/cache-<ver>/<hostname>/<dev>.dat` | `DupPyCore.crc_cache_*` |
| `dup_py.data/cache-*/<hostname>/imagescache.dat` | Image hash cache |

## Where to change what

| Goal | Start here |
|------|------------|
| Fix large-file hashing / 4 GB reads | `core.py` `CRCThreadedCalc.calc`, `_load_zstd_pickle_file` |
| Remove-duplicates toolbar button | `dup_py.py` `groups_toolbar`, `remove_duplicates_button_wrapper`, `update_remove_duplicates_button_state` |
| Scan performance / skip rules | `core.py` `DupPyCore.scan` (~346+) |
| New keyboard shortcut | `dup_py.py` `key_press` (~3038+) |
| New menu action on duplicates | `context_menu_show` (~3730+) + `process_files_core` (~6547+) |
| New CLI flag | `console.py` `parse_args` + `dup_py.py` `__main__` |
| New language string | `text.py` `STR_DICT` + call site `STR('...')` |
| Duplicate grouping UI | `groups_show`, `groups_tree_update` |
