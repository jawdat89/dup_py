@cd "%~dp0.."
@echo building with pyinstaller
@cd src

@set /p VERSION=<version.txt
@SET VERSION=%VERSION:~1,10%
@echo VERSION=%VERSION%

@SET OUTDIR=..\build-pyinstaller

@if exist %OUTDIR% rmdir /s /q %OUTDIR%
@mkdir %OUTDIR%

@echo.
@echo running-pyinstaller
@echo wd:%CD%

@python --version > distro.info.txt
@echo. >> distro.info.txt
@echo|set /p="pyinstaller " >> distro.info.txt
@pyinstaller --version >> distro.info.txt

@echo.
@echo running-pyinstaller-stage_dup_py
pyinstaller --noconfirm --clean --optimize 2 --noupx ^
    --version-file=version.pi.dup_py.txt --icon=icon.ico --windowed ^
    --add-data="distro.info.txt:." --add-data="version.txt;." --add-data="../LICENSE;." ^
    --contents-directory=internal --distpath=%OUTDIR% --name dup_py --additional-hooks-dir=. ^
    --collect-binaries tkinterdnd2 ^
    --hidden-import="PIL._tkinter_finder" ^
    --hidden-import="sklearn.cluster._dbscan_inner_" ^
    dup_py.py || exit /b 2

@echo.
@echo running-pyinstaller-dup_py_cmd
pyinstaller --noconfirm --clean --optimize 2 --noupx ^
    --version-file=version.pi.dup_py_cmd.txt --icon=icon.ico ^
    --add-data="distro.info.txt:." --add-data="version.txt;." --add-data="../LICENSE;." ^
    --distpath=%OUTDIR% --console --contents-directory=internal --name dup_py_cmd ^
    console.py || exit /b 1

move %OUTDIR%\dup_py_cmd\dup_py_cmd.exe %OUTDIR%\dup_py

@echo.
@echo packing
powershell Compress-Archive %OUTDIR%\dup_py %OUTDIR%\dup_py.win.zip
