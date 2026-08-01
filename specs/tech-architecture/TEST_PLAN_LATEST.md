# Test Plan

## Test Strategy
Script-based project with limited automated testing. Relies on:
- Input validation (missing files, invalid paths)
- Error handling (ffmpeg, Nerfstudio commands)
- Manual verification (final output quality)

## Unit Tests

### extract-frames.ps1
- **Input**: Missing video file → **Expected**: Clear error message
- **Input**: Missing output folder → **Expected**: Auto-create directory
- **Input**: Invalid video format → **Expected**: ffmpeg error propagated

### extract-frames.bat
- **Input**: Missing arguments → **Expected**: Usage help displayed
- **Input**: Non-existent video → **Expected**: File not found error
- **Input**: Relative paths → **Expected**: Converted to absolute paths

## Integration Tests
- **Workflow**: Video → Frames → PLY → Web viewer
- **Checkpoints**: Each step validates output before proceeding
- **Fallback**: If local fails, recommend cloud service

## Performance Tests
- **Frame extraction**: 1080p video → 10 seconds/minute
- **Training**: 300 photos → 45-90 minutes on RTX 5060
- **Export**: PLY → 100-500MB file

## Test Execution
```powershell
# Test input validation
.\extract-frames.ps1 -VideoPath "nonexistent.mp4" -OutputPath "frames"

# Test relative paths
cd "C:\photos"
.\extract-frames.ps1 -VideoPath "video.mp4" -OutputPath "frames"

# Test manual verification
# 1. Open PLY in SuperSplat
# 2. Verify visual quality
# 3. Check file size
```

## Test Data
- **Video**: IMG_0471.MOV (sample footage)
- **Photos**: Manual collection (300-500 images)
- **Expected output**: PLY file, web-compatible .spz
