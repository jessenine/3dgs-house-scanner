@echo off
REM =============================================
REM Open 3DGS result in browser viewer
REM Automatically finds the latest .ply file
REM =============================================

echo Opening 3DGS viewer in browser...

REM Find the latest .ply file
for /f "delims=" %%i in ('dir /b /s /o-d C:\output\*.ply 2^>nul') do (
    set PLY_FILE=%%i
    goto :found
)
echo No PLY file found in C:\output\
echo.
echo Training script should have created one at:
echo C:\output\point_cloud\iteration_30000\point_cloud.ply
goto :done

:found
echo PLY file: %PLY_FILE%
echo.
echo Opening browser viewer...
start superspl.at/editor
echo.
echo Drag your PLY file into the browser viewer.
echo PLY file path: %PLY_FILE%
echo.

echo Press any key to exit...
pause >nul
