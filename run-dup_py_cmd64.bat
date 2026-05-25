@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "SCRIPT=%~dp0src\dup_py.py"
set "VENV_PY=%~dp0.venv\Scripts\python.exe"
set "DUP_PY_LAUNCHER=run-dup_py_cmd64.bat"

if exist "%VENV_PY%" (
    "%VENV_PY%" -c "import struct,sys; sys.exit(0 if struct.calcsize('P')==8 else 1)" 1>nul 2>nul
    if not errorlevel 1 (
        "%VENV_PY%" "%SCRIPT%" %*
        exit /b %ERRORLEVEL%
    )
    echo WARN: .venv Python is not 64-bit.
)

where py >nul 2>&1
if not errorlevel 1 (
    py -3-64 -c "import struct,sys; sys.exit(0 if struct.calcsize('P')==8 else 1)" 1>nul 2>nul
    if not errorlevel 1 (
        echo WARN: Using py -3-64 without project venv — install deps: pip install -r requirements.txt
        py -3-64 "%SCRIPT%" %*
        exit /b %ERRORLEVEL%
    )
)

if not exist "%VENV_PY%" (
    echo ERROR: No 64-bit Python found.
    echo   1. Install 64-bit Python from https://www.python.org/downloads/
    echo   2. py -3-64 -m venv .venv
    echo   3. .venv\Scripts\pip install -r requirements.txt
    exit /b 1
)

echo ERROR: .venv exists but is not 64-bit. Recreate with 64-bit Python:
echo   rmdir /s /q .venv
echo   py -3-64 -m venv .venv
echo   .venv\Scripts\pip install -r requirements.txt
exit /b 1
