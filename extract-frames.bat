@echo off
REM =============================================
REM Extract frames from video for 3DGS training
REM Usage: extract-frames.bat "C:\video.mp4" "C:\frames"
REM        extract-frames.bat "..\video.mp4" "..\frames"
REM        extract-frames.bat "video.mp4" "frames"  (uses current dir)
REM =============================================

if "%1"=="" (
    echo ERROR: No video file specified!
    echo.
    echo Usage: extract-frames.bat "C:\path\to\video.mp4" "C:\path\to\output\folder"
    echo Example: extract-frames.bat "C:\photos\IMG_0471.MOV" "C:\photos\frames"
    echo.
    echo Supports relative paths: extract-frames.bat "video.mp4" "frames"
    exit /b 1
)

if "%2"=="" (
    echo ERROR: No output folder specified!
    echo.
    echo Usage: extract-frames.bat "C:\path\to\video.mp4" "C:\path\to\output\folder"
    echo Example: extract-frames.bat "C:\photos\IMG_0471.MOV" "C:\photos\frames"
    echo.
    echo Supports relative paths: extract-frames.bat "video.mp4" "frames"
    exit /b 1
)

set VIDEO=%1
set OUTPUT=%2

REM Convert relative paths to absolute paths
for %%I in ("%VIDEO%") do set "VIDEO_ABS=%%~fI"
for %%I in ("%OUTPUT%") do set "OUTPUT_ABS=%%~fI"

echo ============================================
echo   Extracting Frames from Video
echo ============================================
echo Input (relative): %VIDEO%
echo Video (absolute): %VIDEO_ABS%
echo Output (relative): %OUTPUT%
echo Output (absolute): %OUTPUT_ABS%
echo.

REM Check if video file exists
if not exist "%VIDEO_ABS%" (
    echo ERROR: Video file not found: %VIDEO_ABS%
    echo.
    echo Please check that the path is correct.
    echo Your input was: %VIDEO%
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

REM Check if ffmpeg is installed
ffmpeg -version >nul 2>&1
if %errorLevel% neq 0 (
    echo ffmpeg not found. Installing...
    winget install --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements 2>nul
    if %errorLevel% neq 0 (
        echo ERROR: Failed to install ffmpeg. Please install manually.
        echo.
        echo Press any key to exit...
        pause >nul
        exit /b 1
    )
)

REM Create output directory if it doesn't exist
if not exist "%OUTPUT_ABS%" mkdir "%OUTPUT_ABS%"

REM Extract 1 frame every 0.25 seconds (4 FPS)
echo Extracting frames...
ffmpeg -i "%VIDEO_ABS%" -vf "fps=4" -q:v 2 "%OUTPUT_ABS%\frame_%04d.jpg"

if %errorLevel% neq 0 (
    echo.
    echo ============================================
    echo   ERROR: Frame extraction failed!
    echo ============================================
    echo.
    echo Possible causes:
    echo   - Video file is corrupted or in an unsupported format
    echo   - ffmpeg installation is incomplete
    echo   - Output folder path is invalid
    echo.
    echo Video file: %VIDEO_ABS%
    echo Output folder: %OUTPUT_ABS%
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo.
echo ============================================
echo   Extraction complete!
echo ============================================
echo Frames saved to: %OUTPUT_ABS%
echo You can now use these frames for 3DGS training.
echo.
echo Next steps:
echo   1. Process frames with: python -m nerfstudio.scripts.process_data ^<frames^> ^<output^>
echo   2. Train with: python -m nerfstudio.scripts.train splatfacto ^<options^>
echo.
echo Press any key to exit...
pause >nul
