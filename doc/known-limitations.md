# Known limitations

## ~4 GB read ceiling

**Status:** fixed in local tree (chunked file hashing and streaming cache load in `src/core.py`).

### Research conclusion (OS vs library vs app)

This is **not** a limitation of duplicate-detection libraries (`hashlib`, NumPy, SciPy, etc.). SHA-1 supports unlimited input size when updated in chunks ([Python `hashlib`](https://docs.python.org/3/library/hashlib.html)).

| Layer | Limits a single read? | Notes |
|-------|------------------------|--------|
| **Windows `ReadFile`** | Yes | `nNumberOfBytesToRead` is a 32-bit `DWORD` (~4 GB max per syscall). [ReadFile](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-readfile), [>4 GB reads](https://devblogs.microsoft.com/oldnewthing/20250804-00/?p=111432) |
| **Python I/O on Windows** | Yes, per syscall | `FileIO.read(size)` and `os.read()` clamp requested `size` to `INT_MAX` (~2 GB). [bpo-9611](https://bugs.python.org/issue9611), [bpo-21932](https://bugs.python.org/issue21932) |
| **`hashlib` (SHA-1)** | No | Incremental `update()`; no file-size cap. |
| **Dup_py `CRCThreadedCalc`** | Fixed locally | All file sizes: 1 MB chunked reads. |
| **Dup_py cache load** | Partially mitigated | zstd `stream_reader` reads compressed file incrementally; **decompressed** pickle still must fit in RAM. |

Use **64-bit Python** (`run-dup_py64.bat`) for large files and caches.

### What changed (2026-05)

- `CRCThreadedCalc.calc` — removed the 8 MB whole-file `read()` path; always SHA-1 via 1 MB chunks.
- `_load_zstd_pickle_file` — `ZstdDecompressor.stream_reader` + `pickle.Unpickler` (not one giant `read()` of compressed data).
- `MemoryError` on cache load — skip that device’s cache and log; scan continues.

### Optional follow-up

- Split or stream cache format if decompressed blobs exceed RAM.
- Automated tests with files > 4 GB on Windows.

---

## One scan scope (what counts as “read” in a scan)

**Status:** by design — easy to mistake for a hard file-read cap.

### How a CRC scan works

| Stage | What happens | Limit |
|-------|----------------|--------|
| **Walk** | `os.scandir` over up to **8** roots; every regular file is **stat**’d (not fully read). | Skips: symlinks to dirs, hardlinks (`st_nlink>1`), hidden (optional), exclude masks, min/max **file size** filters. |
| **Size groups** | Only files that share at least one other file of the **same byte size** stay in memory. | Singleton sizes are dropped — never content-hashed. |
| **Hash** | SHA-1 reads **content** only for size-group candidates (1 MB chunks). | Open/read errors logged; file skipped. |
| **Abort** | Cancel during walk **clears** the scan (`reset()`). Cancel during hash may leave **partial** groups. | |
| **Cache** | Per-device `.dat` at start of `crc_calc`. | Decompressed cache must fit in RAM; else skipped (logged). |

“Files in one scan” = files on the chosen paths in **that run**, minus skips and hash failures — not every file on disk.

### Image similarity / GPS mode

- Only `IMAGES_EXTENSIONS` files.
- PIL decompression-bomb limit **off for that scan** (log warning) so very large images can open.
- Failed opens logged and skipped.

### Practical tips

- Narrow paths; use **exclude** masks (`*.git/*`, system trees).
- **Erase Cache** if cache load fails or RAM is tight.
- **`run-dup_py64.bat --debug`** — check `dup_py.data/logs/` for `scan walk done` / `crc_calc done`.

---

## “Remove duplicates” toolbar button

**Status:** fixed in local tree.

### UI

- **Control:** `tkinter.Button` (`TkButton`) on `groups_toolbar`, above the groups tree (standard Windows raised button).
- **Enabled when:** at least one file is in `self.tagged`, scan not running (`scanning_in_progress`), and `block_processing_stack` is empty (no modal lock from `processing_off`).
- **Disabled when:** nothing marked, scan in progress, or a blocking dialog/operation holds the processing stack.

### Action

- Same as **Ctrl+Delete:** `process_files_in_groups_wrapper(DELETE, 1)` — all marked files, with existing confirmations.
- If nothing is marked: dialog **No Files Marked For Processing !**
- Mark from the **folder** panel (**Space** on a file row), then click the button.

### Code / i18n

| Item | Location |
|------|----------|
| Button + state | `dup_py.py` — `groups_toolbar`, `update_remove_duplicates_button_state`, `remove_duplicates_button_wrapper` |
| Strings | `text.py` — `Remove duplicates`, `TOOLTIP_REMOVE_DUPLICATES` |

### Debugging a gray button

```bat
run-dup_py64.bat --debug
```

After marking, log should show `remove_duplicates_button state=normal marked=1` (or higher). If `marked=0`, marks were not applied to file rows in the folder tree.
