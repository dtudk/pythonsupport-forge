@echo off
setlocal EnableExtensions

rem Load conda shell functions from the newly installed prefix and
rem activate the base environment at that same prefix.
call "%PREFIX%\Scripts\activate.bat" "%PREFIX%"
if errorlevel 1 exit /b 1

rem Initialize conda for all supported shells on this machine.
call "%PREFIX%\condabin\conda.bat" init --all
if errorlevel 1 exit /b 1

rem Create PEP 668 EXTERNALLY-MANAGED marker to block pip/uv/poetry in base
rem See PEP 668 for details.
set STDLIB_PATH=
for /f "usebackq delims=" %%p in (`'%PREFIX%\python.exe' -c "import sysconfig; print(sysconfig.get_path('stdlib', sysconfig.get_default_scheme()))"`) do set "STDLIB_PATH=%%p"
if not defined STDLIB_PATH exit /b 1

set "MARKER_FILE=%STDLIB_PATH%\EXTERNALLY-MANAGED"

>  "%MARKER_FILE%" echo "[externally-managed]"
>> "%MARKER_FILE%" echo "Error=This base environment is frozen and cannot be modified."
>> "%MARKER_FILE%" echo ""
>> "%MARKER_FILE%" echo "  To control packages please create a new environment:"
>> "%MARKER_FILE%" echo ""
>> "%MARKER_FILE%" echo "    conda create -n myproject python=3.14 <your-packages>"
>> "%MARKER_FILE%" echo "    conda activate myproject"
>> "%MARKER_FILE%" echo ""
>> "%MARKER_FILE%" echo "  For more information, have a look here:"
>> "%MARKER_FILE%" echo "  https://pythonsupport.dtu.dk/learn-more/packages-and-environments/environments.html"
if errorlevel 1 exit /b 1

exit /b 0
