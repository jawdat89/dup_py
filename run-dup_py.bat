@echo off
setlocal
cd /d "%~dp0"
set "DUP_PY_LAUNCHER=run-dup_py.bat"
".venv\Scripts\python.exe" "src\dup_py.py" %*
