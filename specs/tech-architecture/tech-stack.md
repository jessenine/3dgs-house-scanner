# Tech Stack

## Language & Runtime
- **Primary**: Python 3.10+ (Nerfstudio, scripts)
- **Windows tooling**: PowerShell 7+ (extract-frames.ps1)
- **Legacy fallback**: Batch files (extract-frames.bat)
- **Front-end**: HTML5, CSS3, JavaScript

## Frameworks & Libraries
- **3DGS**: Nerfstudio (splatfacto), OpenSplat
- **GPU**: PyTorch with CUDA 12.6 (cu126) for Blackwell support
- **SfM**: COLMAP (automatic integration via Nerfstudio)
- **Web viewer**: SuperSplat, SIBR Viewer

## Infrastructure
- **Local**: Windows 10/11 with RTX 5060 (12GB VRAM)
- **Cloud**: Polycam, Luma AI, Splat3D, MakeSplat
- **Storage**: Local disk or NAS (for photo collection)

## Build & Deployment
- **Packaging**: Single-file scripts, ZIP distribution
- **Distribution**: GitHub Releases, direct clone
- **CI/CD**: GitHub Actions (future phase)

## Development Stack
- **IDE**: VS Code, PowerShell ISE
- **Version Control**: Git, GitHub
- **Package Manager**: pip (Python), winget (Windows)
- **Testing**: Manual testing, PowerShell Test-Path validation
