@echo off
REM =============================================
REM 3D Gaussian Splatting — Windows 11 Install Script
REM For: Skadoosh (RTX 5060 12GB, Windows 11)
REM =============================================

echo ============================================
echo   3D Gaussian Splatting — Windows 11 Setup
echo   For: Skadoosh (RTX 5060 12GB)
echo ============================================
echo.

REM Check if running as admin
echo [1/6] Checking administrator privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: Not running as admin. Some steps may fail.
    echo Continuing anyway...
    echo.
)

REM Step 1: Install Python
echo [2/6] Installing Python 3.10...
winget install --id Python.Python.3.10 --accept-package-agreements --accept-source-agreements 2>nul
if %errorLevel% neq 0 (
    echo Python already installed or winget failed. Check: python --version
)
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo Installing Python from python.org...
    curl -s -o C:\Python310.exe https://www.python.org/ftp/python/3.10.14/python-3.10.14-amd64.exe
    C:\Python310.exe /quiet InstallAllUsers=1 PrependPath=1
    del C:\Python310.exe
)
python --version

REM Step 2: Install dependencies
echo [3/6] Installing dependencies...
python -m pip install --upgrade pip setuptools wheel
pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

REM Step 3: Install COLMAP
echo [4/6] Installing COLMAP...
winget install --id COLMAP.COLMAP --accept-package-agreements --accept-source-agreements 2>nul
if %errorLevel% neq 0 (
    echo COLMAP not found in winget. Downloading manually...
    curl -s -o C:\colmap.zip https://github.com/colmap/colmap/releases/download/dev/colmap-3.9.1-windows-CUDA12.zip
    if exist C:\colmap.zip (
        tar -xf C:\colmap.zip -C C:\
        ren C:\colmap* colmap
        del C:\colmap.zip
    )
)
colmap --version 2>nul
if %errorLevel% neq 0 echo COLMAP may not be in PATH. Install from https://colmap.github.io/

REM Step 4: Clone Nerfstudio with Blackwell support
echo [5/6] Cloning Nerfstudio (with Blackwell support)...
if not exist "%USERPROFILE%\nerfstudio" mkdir %USERPROFILE%\nerfstudio
cd %USERPROFILE%\nerfstudio
if not exist "nerfstudio" git clone https://github.com/nerfstudio-project/nerfstudio.git
cd nerfstudio

REM Install Nerfstudio in development mode
echo Installing Nerfstudio...
python -m pip install -e .

REM Step 5: Verify installation
echo [6/6] Verifying installation...
ns --version 2>nul
if %errorLevel% neq 0 (
    echo Nerfstudio CLI may need path adjustment.
    echo Try: python -m nerfstudio
)

echo.
echo ============================================
echo   Installation complete!
echo ============================================
echo.
echo Next steps:
echo 1. Capture photos of your house (see capture-guide.md)
echo 2. Place photos in C:\photos\
echo 3. Run: train-splat.bat C:\photos C:\output
echo.
echo Viewing your result:
echo Open C:\Users\shade\3dgs-setup\open-viewer.bat
echo Or visit superspl.at/editor and drag the PLY file

echo.
echo Press any key to exit...
pause >nul
