# Story: Nerfstudio Installation with cu126

## Story ID
e02s01

## Title
Nerfstudio Installation with cu126

## BCPs
5

## Status
failing

## Risk
P1

## Context
Infrastructure - Windows PowerShell environment setup with PyTorch and Nerfstudio

## Requirements

#### ADDED: Create virtual environment and install dependencies
Users MUST be able to set up a clean Python environment with PyTorch cu126 and Nerfstudio for Blackwell GPU support.

**Verification:**
- Virtual environment created with `python -m venv gs-env` → verify: `Test-Path gs-env\Scripts\Activate.ps1`
- PyTorch installed with cu126 → verify: `python -c "import torch; print(torch.version.cuda)"` returns `12.6`
- Nerfstudio installed → verify: `python -m nerfstudio --help` runs without error
- COLMAP installed → verify: `colmap --help` runs without error
- Blackwell GPU detected → verify: `python -c "import torch; print(torch.cuda.get_device_name(0))"` returns RTX 5060

## Steps

1. Create PowerShell installation script with mandatory parameters for venv path and Nerfstudio source → verify: `Test-Path install-nerfstudio.ps1`
2. Implement virtual environment creation with `python -m venv gs-env` → verify: `Test-Path gs-env\Scripts\Activate.ps1`
3. Add pip upgrade step (`pip install --upgrade pip setuptools wheel`) → verify: `pip --version` shows updated pip
4. Implement PyTorch cu126 installation → verify: `python -c "import torch; assert torch.version.cuda == '12.6'"` passes
5. Add Nerfstudio editable install → verify: `python -m nerfstudio --help` shows usage
6. Implement COLMAP winget installation → verify: `colmap --help` shows version info
7. Add Blackwell GPU verification step → verify: `python -c "import torch; assert torch.cuda.is_available(); assert 'RTX 5060' in torch.cuda.get_device_name(0)"` passes
8. Document installation script usage in README-POWERSHELL.md → verify: `Get-Content README-POWERSHELL.md | Select-String "install-nerfstudio.ps1"`

## Verification Script (Step-by-Step)

1. Copy `install-nerfstudio.ps1` to target Windows machine
2. Run `.\install-nerfstudio.ps1 -VenvPath "gs-env" -NerfstudioPath "nerfstudio"`
3. Verify venv created: Check `gs-env\Scripts\Activate.ps1` exists
4. Activate venv: `.\gs-env\Scripts\Activate.ps1`
5. Test PyTorch: Run `python -c "import torch; print(torch.version.cuda)"`
6. Test Nerfstudio: Run `python -m nerfstudio --help`
7. Test COLMAP: Run `colmap --help`
8. Test GPU: Run `python -c "import torch; print(torch.cuda.get_device_name(0))"`

## Out of scope

- Graphical installation wizard (PowerShell CLI only)
- Non-Windows platform support (Windows 10/11 only)
- Custom CUDA version selection (cu126 hardcoded)

## Risks

- **P1 - PyTorch cu126 unavailable**: If PyTorch removes Windows cu126 wheels, use cu124 fallback with patched code
- **P2 - Nerfstudio dependency conflicts**: If conflicts arise, try `splatfacto-small` instead of full `splatfacto`
- **P3 - COLMAP installation timeout**: Winget may timeout; user should run `winget install COLMAP.COLMAP` manually

## Allure

- severity: high
- categories:
  - "Installation"
  - "Infrastructure"
  - "Windows"

## Implementation Notes

- Install script should validate each step and report errors clearly
- Fallback to manual installation if winget fails
- Verify Blackwell compatibility with `torch.version.cuda == '12.6'`
- Document known issues (VRAM requirements, training time estimates)
