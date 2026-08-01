# Story e06s01: Cloud Service API Integration

**type:** feat  
**risk:** P0  
**context:** infra  
**BCPs:** 8  

**Context**: This story establishes API connectivity to Polycam, Luma AI, and Splat3D for photo upload and status polling. This is the critical path for epic e06 - without working API integration, the upload workflow cannot proceed. All three services must be supported because users have different preferences and service capabilities.

## Steps

1. Create `specs/epics/e06-cloud-upload/api/` directory with service-specific modules → verify: `Test-Path specs/epics/e06-cloud-upload/api/polycam.ps1`

2. Implement Polycam API client with upload and status methods → verify: `.\api\polycam.ps1 -Token "test" -PhotoPath "test.jpg" -Action upload`

3. Implement Luma AI API client with upload and status methods → verify: `.\api\luma.ps1 -Token "test" -PhotoPath "test.jpg" -Action upload`

4. Implement Splat3D API client with upload and status methods → verify: `.\api\splat3d.ps1 -Token "test" -PhotoPath "test.jpg" -Action upload`

5. Create unified `api-upload.ps1` that routes to service-specific client → verify: `.\api-upload.ps1 -Service polycam -Token $token -PhotoPath "test.jpg" -Action upload`

6. Implement status polling with configurable interval and timeout → verify: `.\api-upload.ps1 -Service polycam -Token $token -JobId "123" -Action status`

7. Add error handling for network failures, rate limits, and invalid tokens → verify: `.\api-upload.ps1 -Service invalid -Token "" 2>&1 | Should -Throw`

8. Update test plan with API integration scenarios → verify: `Test-Path specs/tech-architecture/e06-TEST_PLAN_LATEST.md`

## Verification Script (Step-by-Step)

1. Verify API directory structure exists
2. Test Polycam upload with valid token
3. Test Luma AI upload with valid token
4. Test Splat3D upload with valid token
5. Test status polling for each service
6. Test error handling for invalid service
7. Test error handling for missing token
8. Verify test plan contains API scenarios

## Out of scope

- Web-based upload form (e09)
- Automatic API token discovery (e10)
- Batch uploads (e08)
- Video input (e01)

## Risks

- **P0 - API rate limits**: Services may throttle uploads. Detect by HTTP 429 response codes; handle with exponential backoff.
- **P0 - Token validation**: Invalid tokens will cause immediate failures. Detect by HTTP 401 responses; guide user to re-enter token.
- **P1 - File size limits**: Large photo sets may exceed service limits. Detect by HTTP 413; prompt user to reduce photo count.
- **P2 - Network timeouts**: Slow internet may cause upload failures. Detect by timeout exceptions; retry with longer timeout.
- **P3 - Documentation**: API docs may change. Verify with `web_search` before implementation.

## Verify

→ verify: `Test-Path specs/epics/e06-cloud-upload/api/*.ps1`
