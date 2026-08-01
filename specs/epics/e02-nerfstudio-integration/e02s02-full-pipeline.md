# Story: Full PowerShell Pipeline

## Story ID
e02s02

## Title
Full PowerShell Pipeline (Process → Train → Export)

## BCPs
6

## Status
failing

## Risk
P1

## Context
Infrastructure - End-to-end 3DGS pipeline with Nerfstudio

## Requirements

#### ADDED: Create PowerShell scripts for full 3DGS workflow
Users MUST be able to process photos, train a model, and export PLY with single commands.

**Verification:**
- Process data creates COLMAP output → verify: `Test-Path C:\output\data\sparse\0\images.bin`
- Train creates model checkpoints → verify: `Test-Path C:\output\results\splatfacto\config.yml`
- Export creates PLY file → verify: `Test-Path C:\output\point_cloud\iteration_30000\point_cloud.ply`

## Steps

1. Create `process-data.ps1` with photo and output paths → verify: `Test-Path process-data.ps1`
2. Implement COLMAP SfM invocation via `python -m nerfstudio.scripts.process_data` → verify: `Test-Path output\data\sparse\0\images.bin`
3. Create `train.ps1` with data path and output directory → verify: `Test-Path train.ps1`
4. Implement splatfacto training with configurable iterations → verify: `Test-Path output\results\splatfacto\config.yml`
5. Create `export.ps1` with config and output path → verify: `Test-Path export.ps1`
6. Implement PLY export with correct iteration path → verify: `Test-Path output\point_cloud\iteration_30000\point_cloud.ply`
7. Add web server notification (http://localhost:7562) → verify: `Test-NetConnection -ComputerName localhost -Port 7562`
8. Document pipeline commands in README-POWERSHELL.md → verify: `Get-Content README-POWERSHELL.md | Select-String "process-data.ps1"` and similar for train/export

## Verification Script (Step-by-Step)

1. Prepare photos folder with 300-500 images
2. Run `.\process-data.ps1 -PhotoPath C:\photos -OutputPath C:\output`
3. Wait for COLMAP processing (10-30 minutes)
4. Verify output: `Test-Path C:\output\data\sparse\0\images.bin`
5. Run `.\train.ps1 -DataPath C:\output\data -OutputPath C:\output\results`
6. Monitor training at http://localhost:7562 (45-90 minutes)
7. Verify model saved: `Test-Path C:\output\results\splatfacto\config.yml`
8. Run `.\export.ps1 -ConfigPath C:\output\results\config.yml -OutputPath C:\output\point_cloud`
9. Verify PLY: `Test-Path C:\output\point_cloud\iteration_30000\point_cloud.ply`
10. Open PLY in SuperSplat: https://superspl.at/editor

## Out of scope

- Cloud processing integration (local pipeline only)
- Real-time preview during training
- Export to .spz or .sog formats (future phase)

## Risks

- **P1 - Training out of VRAM**: If RTX 5060 runs out of memory, reduce photo count or use `splatfacto-small`
- **P1 - COLMAP fails**: If SfM fails, check image quality and overlap percentage
- **P2 - Web server port blocked**: If port 7562 blocked, check Windows Firewall settings
- **P3 - Export path mismatch**: If config specifies different output path, use path from config file

## Allure

- severity: high
- categories:
  - "Pipeline"
  - "Automation"
  - "PowerShell"

## Implementation Notes

- All scripts should use absolute paths for reliability
- Process script should validate photo count (300-500 recommended)
- Train script should show training progress and web URL
- Export script should validate config file exists before processing
