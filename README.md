# 3D Gaussian Splatting — House Scanner

This repository contains tools for creating 3D Gaussian Splatting (3DGS) models of your house from photos or video.

## Features

- **PowerShell scripts** for Windows (no batch files)
- **Relative path support** - work from any directory
- **PowerShell provider path support** - works when invoked from UNC paths
- **Automatic ffmpeg installation** via winget
- **Full Nerfstudio integration** for training and export

## Quick Start

### 1. Extract Frames from Video (Optional)

```powershell
# If you have video footage
.\extract-frames.ps1 -VideoPath "video.mp4" -OutputPath "frames"
```

### 2. Install Prerequisites

```powershell
# Install Python 3.10
winget install --id Python.Python.3.10 --accept-package-agreements

# Install Nerfstudio
git clone https://github.com/nerfstudio-project/nerfstudio.git
cd nerfstudio
pip install -e .
```

### 3. Process Your Photos

```powershell
python -m nerfstudio.scripts.process_data C:\photos C:\output --data-type images
```

### 4. Train the Model

```powershell
python -m nerfstudio.scripts.train splatfacto `
  --data C:\output\data `
  --output-dir C:\output\results `
  --load-config ""
```

### 5. Export and View

```powershell
python -m nerfstudio.scripts.export --load-config C:\output\results\config.yml --output-path C:\output\point_cloud

# View in browser
Start-Process "https://superspl.at/editor"
```

## Files

- `extract-frames.ps1` - Extract frames from video
- `extract-frames.bat` - Same as above, but batch file
- `README-POWERSHELL.md` - Full PowerShell setup guide
- `capture-guide.md` - Photo capture guidelines
- `index.html` - Interactive web interface

## RTX 5060 (Blackwell) Support

For Windows 11 with RTX 5060, use **CUDA 12.6**:
```powershell
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
```

## Troubleshooting

See `README-POWERSHELL.md` for detailed troubleshooting guides.
