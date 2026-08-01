# Security Plan

## Asset Classification
- **Public**: Scripts, documentation, web front-end
- **Private**: User-uploaded photos (handled by cloud services)
- **Local**: Trained models, PLY exports

## Threat Model

### Local Processing
- **Threat**: GPU driver vulnerabilities
  - **Mitigation**: Keep NVIDIA drivers updated (551+)
  
- **Threat**: Malicious scripts
  - **Mitigation**: Code review before execution
  - **Mitigation**: Windows SmartScreen warnings

### Cloud Processing
- **Threat**: Photo data exposure
  - **Mitigation**: Use reputable services (Polycam, Luma AI)
  - **Mitigation**: Delete local copies after upload

### Data Protection
- **Photos**: Delete after successful upload or processing
- **Models**: Local storage only, no automatic upload
- **Logs**: No sensitive data in scripts

## Access Control
- **Local**: User account only (no shared credentials)
- **Cloud**: User account credentials
- **Repository**: GitHub authentication

## Audit Trail
- **Git commits**: Track all code changes
- **Execution logs**: PowerShell/Python scripts log to console
- **Error handling**: All failures logged to stdout
