# Story: Blackwell GPU Compatibility Verification

## Story ID
e02s03

## Title
Blackwell GPU Compatibility Verification

## BCPs
4

## Status
failing

## Risk
P0

## Context
Infrastructure - CUDA architecture verification for RTX 5060 (sm_120)

## Requirements

#### ADDED: Verify Blackwell GPU compatibility before training
Users MUST be able to confirm their RTX 5060 GPU is properly detected and supports cu126.

**Verification:**
- GPU detected by PyTorch → verify: `python -c "import torch; assert torch.cuda.is_available()"` passes
- CUDA version matches cu126 → verify: `python -c "import torch; assert torch.version.cuda == '12.6'"` passes
- GPU name contains RTX 5060 → verify: `python -c "import torch; assert 'RTX 5060' in torch.cuda.get_device_name(0)"` passes
- VRAM sufficient for 300-500 photos → verify: `python -c "import torch; assert torch.cuda.get_device_properties(0).total_memory / 1e9 >= 12"` passes

## Steps

1. Create `verify-gpu.ps1` script with mandatory parameters → verify: `Test-Path verify-gpu.ps1`
2. Implement PyTorch GPU detection → verify: `python -c "import torch; print(f'GPU available: {torch.cuda.is_available()}')"`
3. Add CUDA version check → verify: `python -c "import torch; assert torch.version.cuda == '12.6'"`
4. Implement GPU name verification → verify: `python -c "import torch; print(f'GPU: {torch.cuda.get_device_name(0)}')"`
5. Add VRAM check for 300-500 photo models → verify: `python -c "import torch; print(f'VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB')"`
6. Check compute capability matches sm_120 (12.0) → verify: `python -c "import torch; print(f'Compute: {torch.cuda.get_device_capability(0)}')"`
7. Document verification steps in README-POWERSHELL.md → verify: `Get-Content README-POWERSHELL.md | Select-String "verify-gpu.ps1"`
8. Add troubleshooting section for common GPU issues → verify: `Get-Content README-POWERSHELL.md | Select-String "PyTorch can't find your RTX 5060 GPU"`

## Verification Script (Step-by-Step)

1. Copy `verify-gpu.ps1` to target machine
2. Run `.\verify-gpu.ps1`
3. Verify output shows:
   - GPU available: True
   - CUDA version: 12.6
   - GPU name: NVIDIA RTX 5060
   - VRAM: 12.0 GB (minimum)
   - Compute capability: (12, 0)
4. If any check fails, follow troubleshooting steps in README

## Out of scope

- Driver installation (assumes NVIDIA 551+ drivers installed)
- Multi-GPU setup (single GPU verification only)
- Linux platform support (Windows 10/11 only)

## Risks

- **P0 - GPU not detected**: If PyTorch can't see the GPU, install latest NVIDIA drivers (551+) and verify CUDA installation
- **P0 - Wrong CUDA version**: If cu121 or cu124 installed, uninstall and reinstall cu126
- **P1 - Insufficient VRAM**: If RTX 5060 shows <12GB, check for reserved VRAM or driver issues
- **P2 - Compute capability mismatch**: If sm_120 not supported, use patched code with `-DCMAKE_CUDA_ARCHITECTURES="120"`

## Allure

- severity: critical
- categories:
  - "GPU"
  - "Blackwell"
  - "CUDA"
  - "Verification"

## Implementation Notes

- Script should exit with code 1 if any verification fails
- Provide clear error messages with solution steps
- Include `nvcc --version` check for CUDA toolkit installation
- Recommend running `python -c "import torch; print(torch.__version__)"` first to verify PyTorch installation
