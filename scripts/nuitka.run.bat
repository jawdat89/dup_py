@cd "%~dp0.."
@echo building with nuitka
@cd src

@set /p VERSION=<version.txt
@SET VERSION=%VERSION:~1,10%
@echo VERSION=%VERSION%

@SET OUTDIR=..\build-nuitka

@if exist %OUTDIR% rmdir /s /q %OUTDIR%
@mkdir %OUTDIR%

@echo.
@echo running-nuitka
@echo wd:%CD%

@echo|set /p="Nuitka " > distro.info.txt
python -m nuitka --version >> distro.info.txt

@echo.
@echo running-nuitka-stage_dup_py
python -m nuitka --windows-icon-from-ico=./icon.ico --include-data-file=./distro.info.txt=./distro.info.txt --include-data-file=./version.txt=./version.txt --include-data-file=../LICENSE=./LICENSE --output-dir=%outdir% --standalone --lto=yes --follow-stdlib --assume-yes-for-downloads --product-version=%VERSION% --copyright="2022-2026 Piotr Jochymek" --file-description="Dup_py" --enable-plugin=tk-inter --disable-console --output-filename=dup_py ./dup_py.py || exit /b 2

@echo.
@echo running-nuitka-stage_dup_py_cmd
python -m nuitka --windows-icon-from-ico=./icon.ico --include-data-file=./distro.info.txt=./distro.info.txt --include-data-file=./version.txt=./version.txt --include-data-file=../LICENSE=./LICENSE --output-dir=%outdir% --standalone --lto=yes --follow-stdlib --assume-yes-for-downloads --product-version=%VERSION% --copyright="2022-2026 Piotr Jochymek" --file-description="Dup_py" ./console.py --enable-console --output-filename=dup_py_cmd || exit /b 2

move %OUTDIR%\console.dist\dup_py_cmd.exe %OUTDIR%\dup_py.dist
move %OUTDIR%\dup_py.dist %OUTDIR%\dup_py

@echo.
@echo packing
powershell Compress-Archive %OUTDIR%\dup_py %OUTDIR%\dup_py.win.zip

