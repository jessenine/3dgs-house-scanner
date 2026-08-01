# 3D Gaussian Splatting — PowerShell Commands (No Batch Files)

## ⚠️ SmartScreen Warning

Windows SmartScreen may block the `.bat` files since they came from the Linux shared folder.

**Fix (run in PowerShell):**
```powershell
Get-ChildItem *.bat | Unblock-File
```

**Better option:** Skip batch files entirely — use the PowerShell commands below.

---

## ⚠️ RTX 5060 (Blackwell) Important Note

Your RTX 5060 uses **Blackwell architecture (sm_120)**.

For Windows 11, use **CUDA 12.6** which has Windows wheels available:
```powershell
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
```

For Linux or if you need the absolute latest Blackwell support, use **cu124** with patched 3DGS code like `feiyunwill/gaussian-splatting-cuda`.

---

## Optional: Extract Frames from Video

If you have video footage instead of photos, extract frames first:

```powershell
# Using the PowerShell script (supports relative paths!)
.\extract-frames.ps1 -VideoPath "video.mp4" -OutputPath "frames"

# Or using batch file (also supports relative paths!)
extract-frames.bat "video.mp4" "frames"

# Or using ffmpeg directly (absolute paths)
ffmpeg -i C:\path\to\video.mp4 -vf "fps=4" -q:v 2 C:\path\to\frames\frame_%04d.jpg
```

**Note:** Both batch and PowerShell scripts support relative paths:
- `extract-frames.bat "video.mp4" "frames"` - uses current directory
- `extract-frames.bat "../video.mp4" "../frames"` - goes up one level

After extracting frames, use the output folder as input for the 3DGS pipeline.

---

## Quick Start — PowerShell Only

### Step 0: Install Prerequisites (one time)

```powershell
# Install Python 3.10 (if not already installed)
python --version

# If not found, try:
py --version

# If neither works, install Python:
winget install --id Python.Python.3.10 --accept-package-agreements
```

### Step 1: Create Virtual Environment & Install Dependencies

```powershell
# Create virtual environment
python -m venv gs-env

# Activate it
.\gs-env\Scripts\Activate.ps1

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install PyTorch with CUDA 12.6 (for Blackwell/RTX 5060 support)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# Install COLMAP (for SfM processing)
winget install --id COLMAP.COLMAP --accept-package-agreements
```

### Step 2: Install Nerfstudio

```powershell
# Clone Nerfstudio
cd $HOME\nerfstudio
if (-not (Test-Path "nerfstudio")) { git clone https://github.com/nerfstudio-project/nerfstudio.git }

# Install in development mode
cd nerfstudio
pip install -e .
```

### Step 3: Process Your Photos (COLMAP SfM)

```powershell
# Replace C:\photos with your photo folder
python -m nerfstudio.scripts.process_data C:\photos C:\output --data-type images
```

This runs COLMAP automatically and creates `C:\output\data\` with camera poses and sparse point cloud.

### Step 4: Train the Splat (45-90 minutes)

```powershell
python -m nerfstudio.scripts.train splatfacto `
  --data C:\output\data `
  --output-dir C:\output\results `
  --load-config ""
```

**Monitor progress:** The command will start a web server. Open `http://localhost:7562` in your browser to watch the training.

### Step 5: Export the PLY

```powershell
python -m nerfstudio.scripts.export --load-config C:\output\results\config.yml --output-path C:\output\point_cloud
```

Result: `C:\output\point_cloud\iteration_30000\point_cloud.ply`

### Step 6: View in Browser

```powershell
# Open SuperSplat editor
Start-Process "https://superspl.at/editor"
```

Then drag the `.ply` file into the browser.

---

## Full Pipeline — One Command at a Time

| Step | Command |
|---|---|
| **Activate venv** | `.\gs-env\Scripts\Activate.ps1` |
| **Process photos** | `python -m nerfstudio.scripts.process_data C:\photos C:\output --data-type images` |
| **Train model** | `python -m nerfstudio.scripts.train splatfacto --data C:\output\data --output-dir C:\output\results --load-config ""` |
| **Export PLY** | `python -m nerfstudio.scripts.export --load-config C:\output\results\config.yml --output-path C:\output\point_cloud` |
| **View** | `Start-Process "https://superspl.at/editor"` |

---

## Troubleshooting

### "conda: The term 'conda' is not recognized"

You don't need conda! The guide above uses plain `python -m venv` instead. Just run:

```powershell
python -m venv gs-env
.\gs-env\Scripts\Activate.ps1
```

### "python: The term 'python' is not recognized"

Try `py` instead (Windows Python launcher):

```powershell
py -m venv gs-env
.\gs-env\Scripts\Activate.ps1
py -m pip install ...
```

### "SmartScreen blocked an app"

Right-click each `.bat` file → Properties → at bottom, check "Unblock" → OK

Or in PowerShell:
```powershell
Get-ChildItem *.bat | Unblock-File
```

### Training is slow / out of VRAM

Your RTX 5060 has 12 GB VRAM, which is sufficient. If you run out:
- Use fewer photos (subsample to 200)
- Close other GPU-using apps
- Try `splatfacto-small` instead of `splatfacto`

### "Could not find a version that satisfies the requirement torch"

This happens because:
1. You used wrong CUDA version index
2. Or PyTorch doesn't support your Python version yet

**Fix:** Make sure you're using `cu126`:
```powershell
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
```

### PyTorch can't find your RTX 5060 GPU

Blackwell (sm_120) support is still maturing. After installing, verify:

```powershell
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
```

If CUDA isn't available:
- Install the latest NVIDIA drivers (551+)
- Check CUDA installation: `nvcc --version`

---

## Notes

- **After reboot:** Reactivate venv with `.\gs-env\Scripts\Activate.ps1`
- **To deactivate venv:** `deactivate`
- **COLMAP path:** If COLMAP isn't found, add it to PATH or use full path
- **OpenSplat alternative:** If Nerfstudio seems complex, just download [OpenSplat](https://github.com/pierotofy/OpenSplat/releases)
