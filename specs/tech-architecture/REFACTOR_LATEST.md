# Refactor Plan

## Current State
- Initial release with working scripts
- No major technical debt identified
- Clean separation of concerns

## Potential Improvements

### 1. Script Consolidation
**Issue**: Multiple scripts (extract-frames, install-nerfstudio, train-splat, open-viewer)
**Solution**: Single command-line tool with subcommands
```powershell
./3dgs-tool.ps1 extract -video video.mp4 -output frames
./3dgs-tool.ps1 train -photos frames -output results
./3dgs-tool.ps1 export -input results -output point_cloud
```

### 2. Error Recovery
**Issue**: Failed ffmpeg installation blocks workflow
**Solution**: Fallback to cloud processing if local fails

### 3. Configuration Management
**Issue**: Hardcoded paths (e.g., `C:\photos`, `C:\output`)
**Solution**: Config file with sensible defaults

### 4. Web Front-End Enhancement
**Issue**: Static HTML with no dynamic features
**Solution**: Add JavaScript for:
- Photo count validation
- Overlap percentage calculator
- Progress tracking

## Priority Matrix

| Task | Effort | Impact | Priority |
|------|--------|--------|----------|
| Script consolidation | Medium | High | P1 |
| Error recovery | Medium | High | P1 |
| Config file | Low | Medium | P2 |
| Web enhancements | High | Medium | P3 |

## Breaking Changes
None expected for v1.0.0

## Migration Path
- Current scripts → New consolidated tool (optional)
- All new projects use consolidated tool
- Legacy scripts deprecated in v1.1.0
