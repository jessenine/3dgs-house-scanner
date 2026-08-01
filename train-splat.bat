@echo off
REM =============================================
REM Train 3D Gaussian Splat from photos
REM Usage: train-splat.bat "C:\photos" "C:\output"
REM =============================================

if "%1"=="" (
    echo Usage: train-splat.bat "C:\photos" "C:\output"
    exit /b 1
)

if "%2"=="" (
    echo Usage: train-splat.bat "C:\photos" "C:\output"
    exit /b 1
)

set PHOTOS_DIR=%1
set OUTPUT_DIR=%2

echo ============================================
echo   Training 3D Gaussian Splat
echo ============================================
echo Photos: %PHOTOS_DIR%
echo Output: %OUTPUT_DIR%
echo.

REM Step 1: Process images (COLMAP)
echo [1/3] Processing images with COLMAP...
cd %USERPROFILE%\nerfstudio\nerfstudio
python -m nerfstudio.scripts.process_data %PHOTOS_DIR% %OUTPUT_DIR% --data-type images

if %errorLevel% neq 0 (
    echo COLMAP processing failed. Check logs.
    exit /b 1
)

REM Step 2: Train the splat
echo [2/3] Training 3D Gaussian Splat...
python -m nerfstudio.scripts.train splatfacto --data %OUTPUT_DIR%/data --output-dir %OUTPUT_DIR%/results --load-config ""

if %errorLevel% neq 0 (
    echo Training failed. Check logs.
    exit /b 1
)

REM Step 3: Export the PLY file
echo [3/3] Exporting PLY file...
python -m nerfstudio.scripts.export --load-config %OUTPUT_DIR%/results/config.yml --output-path %OUTPUT_DIR%/point_cloud/

echo.
echo ============================================
echo   Training complete!
echo ============================================
echo Result: %OUTPUT_DIR%\point_cloud\iteration_30000\point_cloud.ply
echo.
echo To view:
echo Open C:\Users\shade\3dgs-setup\open-viewer.bat
echo Or visit superspl.at/editor and drag the PLY file

echo.
echo Press any key to exit...
pause >nul
