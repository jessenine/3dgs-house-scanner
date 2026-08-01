# Story e06s02: PowerShell Upload Tool

**type:** feat  
**risk:** P1  
**context:** infra  
**BCPs:** 5  

**Context**: This story delivers the user-facing upload.ps1 script with all required CLI parameters. The script orchestrates API calls, validates inputs, and displays progress. It's the main interface for users to upload photos to cloud services. All validation must happen before API calls to avoid unnecessary network traffic.

## Steps

1. Create `upload.ps1` with mandatory parameters (-Service, -PhotoPath, -OutputPath) → verify: `.\upload.ps1 -Service polycam -PhotoPath "C:\photos" -OutputPath "C:\output" -Token $token`

2. Add service name validation (polycam|luma|splat3d only) → verify: `.\upload.ps1 -Service invalid -PhotoPath "C:\photos" -OutputPath "C:\output" -Token $token 2>&1 | Should -Contain "Invalid service"`

3. Add API token validation (required, non-empty) → verify: `.\upload.ps1 -Service polycam -PhotoPath "C:\photos" -OutputPath "C:\output" 2>&1 | Should -Contain "API token required"`

4. Add photo path validation (directory exists, contains images) → verify: `.\upload.ps1 -Service polycam -PhotoPath "C:\invalid" -OutputPath "C:\output" -Token $token 2>&1 | Should -Contain "not found"`

5. Add progress display with upload percentage → verify: `.\upload.ps1 -Service polycam -PhotoPath "C:\photos" -OutputPath "C:\output" -Token $token | Should -Contain "Upload: 50%"`

6. Integrate with API client from e06s01 → verify: `.\upload.ps1 -Service polycam -PhotoPath "C:\photos" -OutputPath "C:\output" -Token $token`

7. Add output path validation and directory creation → verify: `Test-Path "C:\output"` after running upload

8. Update documentation with upload.ps1 usage → verify: `Test-Path README-UPLOAD.md`

## Verification Script (Step-by-Step)

1. Run upload.ps1 with all valid parameters
2. Verify error for invalid service name
3. Verify error for missing API token
4. Verify error for non-existent photo path
5. Verify progress output contains percentage
6. Verify output directory is created
7. Verify README-UPLOAD.md exists

## Out of scope

- Web-based upload form (e09)
- Background processing (run upload.ps1 via scheduled task)
- Automatic retry on network failure (e06s01 handles basic retry)

## Risks

- **P1 - Photo count validation**: User may exceed service limits. Detect by counting photos before upload; warn if >500.
- **P1 - File format validation**: Non-image files in photo directory. Detect by filtering for .jpg/.jpeg/.png; warn if invalid files present.
- **P2 - Path length issues**: Windows path length limits may fail. Detect by Try/Catch on path operations; guide to shorter paths.
- **P3 - Output overwrite**: User may overwrite existing results. Detect by checking if output files exist; prompt for overwrite confirmation.

## Verify

→ verify: `Test-Path upload.ps1`
