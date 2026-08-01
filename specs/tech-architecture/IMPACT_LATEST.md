# Impact Analysis

## Recent Changes
- Initial repository creation
- PowerShell scripts with relative path support
- Cloud vs local processing guidance
- RTX 5060 (Blackwell) compatibility

## Affected Components

### 1. extract-frames.ps1
**Changes**: Added `Convert-ToWindowsPath` function for PowerShell provider paths
**Impact**: 
- ✅ Fixes UNC path issues
- ✅ Maintains backward compatibility with absolute paths
- ✅ No breaking changes

**Testing**:
- Test with `Microsoft.PowerShell.Core\FileSystem::\\server\path`
- Test with relative paths (`.`, `..`)
- Test with absolute paths

### 2. README-POWERSHELL.md
**Changes**: Added frame extraction section, relative path examples
**Impact**:
- ✅ No code changes
- ✅ Documentation only

### 3. specs/ directory
**Changes**: New bigpowers structure
**Impact**:
- ✅ Planning documentation
- ✅ No runtime changes

## Dependency Matrix

| Component | Depends On | Breaking Changes | Migration Required |
|-----------|------------|------------------|-------------------|
| extract-frames.ps1 | ffmpeg, PowerShell 5+ | None | None |
| Nerfstudio | Python 3.10+, PyTorch, COLMAP | None | None |
| Web front-end | None (static) | None | None |

## Rollback Plan
If issues arise:
1. Revert to previous commit
2. Use backup files (`index.html.backup`, `index.html.bak`)
3. Restore original batch files if PowerShell fails

## Rollout Strategy
1. ✅ Current state: Initial release ready
2. Next: Test on Windows 11 RTX 5060
3. Next: Document known issues
4. Next: Release v1.0.0
