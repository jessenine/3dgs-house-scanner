# Design Plan

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Web Front-End (index.html)             │
│  - Tab navigation                                           │
│  - Tool comparison                                          │
│  - Capture guide                                            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Photo/Video Input Layer                  │
│  - Local photos (folder)                                    │
│  - Video footage (MP4/MOV/AVI)                              │
│  - Cloud uploads (Polycam/Luma/Splat3D)                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Preprocessing Layer                      │
│  ┌──────────────────┐      ┌──────────────────┐            │
│  │  Frame Extractor │      │  Photo Import    │            │
│  │  (extract-frames│      │  (folder)          │            │
│  │  .ps1/.bat)      │      │                  │            │
│  └────────┬─────────┘      └──────────────────┘            │
│           │                                                 │
│           ▼                                                 │
│  ┌──────────────────────────────────┐                      │
│  │       COLMAP SfM Processing      │                      │
│  │  - Feature extraction            │                      │
│  │  - Camera pose estimation        │                      │
│  │  - Sparse point cloud            │                      │
│  └──────────────────────────────────┘                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Training Layer                           │
│  ┌──────────────────┐      ┌──────────────────┐            │
│  │  Splatfacto      │      │  Splatfacto-Small│            │
│  │  (full 3DGS)     │      │  (lower VRAM)    │            │
│  └────────┬─────────┘      └──────────────────┘            │
│           │                                                 │
│           ▼                                                 │
│  ┌──────────────────────────────────┐                      │
│  │      GPU Processing (CUDA)       │                      │
│  │  - PyTorch with cu126            │                      │
│  │  - Blackwell (sm_120) support    │                      │
│  └──────────────────────────────────┘                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Export & Viewer Layer                    │
│  ┌──────────────────┐      ┌──────────────────┐            │
│  │  Export to .ply  │      │  Export to .spz  │            │
│  └────────┬─────────┘      └──────────────────┘            │
│           │                           │                     │
│           ▼                           ▼                     │
│  ┌──────────────────┐      ┌──────────────────┐            │
│  │  SuperSplat      │      │  SIBR Viewer     │            │
│  │  (browser)       │      │  (desktop)       │            │
│  └──────────────────┘      └──────────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

### 1. extract-frames.ps1
- Accept video path and output folder
- Convert relative paths to absolute
- Install ffmpeg if missing
- Extract frames at 4 FPS
- Report errors with helpful messages

### 2. Nerfstudio Pipeline
- Run `process_data` for COLMAP SfM
- Run `train splatfacto` for Gaussian training
- Run `export` for PLY/SPZ output

### 3. Web Front-End (index.html)
- Tab navigation between tools
- Cloud service comparison table
- Capture guide with checklist
- Clickable links to external tools

## Design Patterns

### Error Handling
- Try-catch with clear error messages
- User guidance on next steps
- Log file paths for debugging

### Relative Path Support
- PowerShell: `Convert-ToWindowsPath` function
- Batch: `for %%I in ("%VIDEO%") do set "VIDEO_ABS=%%~fI"`
- Consistent output of both relative and absolute paths

### Cross-Platform
- PowerShell (Windows)
- Batch (Windows fallback)
- Python (cross-platform for Nerfstudio)

## Future Enhancements

### Phase 2: 2D Floor Plan
- Extract floor plans from 3D models
- Auto-generate room boundaries
- Export to CAD formats

### Phase 3: Mobile App
- iOS/Android photo capture
- Real-time preview
- Cloud processing integration
