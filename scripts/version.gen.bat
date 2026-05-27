@cd "%~dp0..\src"

@echo writing version
python version.py

@echo writing distro.info.txt
python --version > distro.info.txt
echo.>> distro.info.txt
echo development build>> distro.info.txt
