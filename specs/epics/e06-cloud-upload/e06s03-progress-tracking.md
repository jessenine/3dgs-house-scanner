# Story e06s03: Progress Tracking

**type:** feat  
**risk:** P1  
**context:** infra  
**BCPs:** 5  

**Context**: This story adds real-time progress tracking to the upload process. Users need visibility into upload percentage, processing status, and estimated completion time. This reduces anxiety and allows users to plan their workflow. The status polling uses the API client from e06s01 with configurable intervals.

## Steps

1. Implement upload progress display (percentage 0-100%) → verify: `.\upload.ps1 | Should -Contain "Upload: 75%"`

2. Add processing status polling from API → verify: `.\upload.ps1 | Should -Contain "Processing: queued"` and `Should -Contain "Processing: completed"`

3. Calculate and display estimated completion time → verify: `.\upload.ps1 | Should -Contain "Estimated: 45 min"`

4. Implement automatic download after processing completes → verify: `Test-Path "C:\output\results.ply" -or Test-Path "C:\output\results.spz"`

5. Add timeout handling (90 minutes max) → verify: `.\upload.ps1 | Should -Contain "Timeout: 90 minutes exceeded"`

6. Handle failed processing with error guidance → verify: `.\upload.ps1 | Should -Contain "Processing failed"` and guidance on next steps

7. Update status display for each service → verify: `.\upload.ps1 -Service luma | Should -Contain "Processing: queued"`

8. Add verbose mode for detailed logs → verify: `.\upload.ps1 -Verbose | Should -Contain "DEBUG:"` lines

## Verification Script (Step-by-Step)

1. Run upload and verify progress percentage display
2. Run upload and verify processing status changes
3. Run upload and verify estimated completion time
4. Verify output file downloaded automatically
5. Test timeout handling (mock long processing time)
6. Test failed processing error message
7. Test verbose mode for detailed logs

## Out of scope

- Progress bar UI (console only)
- Email notifications on completion (e10 for notification system)
- Resume interrupted uploads (future enhancement)

## Risks

- **P1 - Polling interval too frequent**: Services may rate-limit status requests. Detect by HTTP 429; implement exponential backoff (30s initial, double on each 429).
- **P1 - Status parsing failures**: API response format may change. Detect by Try/Catch on JSON parsing; fallback to raw response for debugging.
- **P2 - Download failures**: Large files may fail during download. Detect by file size mismatch; retry with smaller chunks.
- **P3 - Time calculation accuracy**: Estimated time may be wrong. Detect by comparing actual vs estimated; adjust algorithm for next upload.

## Verify

→ verify: `.\upload.ps1 | Select-String "Upload:", "Processing:", "Estimated:"`
