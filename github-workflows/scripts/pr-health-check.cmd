@echo off
REM Comprehensive PR health check
REM Usage: pr-health-check.cmd <pr-number>

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: pr-health-check.cmd ^<pr-number^>
    exit /b 1
)

set PR_NUMBER=%~1

echo ============================================================
echo            PR #%PR_NUMBER% HEALTH CHECK
echo ============================================================
echo.

REM Get basic PR info using template to parse fields safely
for /f "tokens=1,2,3,4,5 delims=|" %%a in ('gh pr view %PR_NUMBER% --json title,state,mergeable,isDraft,reviewDecision --template "{{.title}}|{{.state}}|{{.mergeable}}|{{.isDraft}}|{{.reviewDecision}}" 2^>nul') do (
    set TITLE=%%a
    set STATE=%%b
    set MERGEABLE=%%c
    set IS_DRAFT=%%d
    set REVIEW_DECISION=%%e
)

if "%TITLE%"=="" (
    echo ❌ ERROR: PR #%PR_NUMBER% not found
    exit /b 1
)

echo 📋 %TITLE%
echo.

set ISSUES_FOUND=0

REM Check 1: Draft status
if "%IS_DRAFT%"=="true" (
    echo ⚠️  DRAFT PR - Mark as ready for review when complete
    set ISSUES_FOUND=1
)

REM Check 2: Mergeability
if "%MERGEABLE%"=="MERGEABLE" (
    echo ✅ Mergeable - No merge conflicts
) else if "%MERGEABLE%"=="CONFLICTING" (
    echo ❌ CONFLICTING - Has merge conflicts that must be resolved
    set ISSUES_FOUND=1
) else (
    echo ⏳ Mergeability unknown - GitHub is still checking...
)

REM Check 3: Review status
if "%REVIEW_DECISION%"=="APPROVED" (
    echo ✅ Reviews: Approved
) else if "%REVIEW_DECISION%"=="CHANGES_REQUESTED" (
    echo ❌ Reviews: Changes requested
    set ISSUES_FOUND=1
) else if "%REVIEW_DECISION%"=="REVIEW_REQUIRED" (
    echo ⏳ Reviews: Review required
) else (
    echo ℹ️  Reviews: %REVIEW_DECISION%
)

REM Check 4: CI Status
echo.
echo CI Checks:
gh pr checks %PR_NUMBER% > nul 2>&1
if %ERRORLEVEL% equ 0 (
    gh pr checks %PR_NUMBER% | findstr /C:"fail" > nul
    if !ERRORLEVEL! equ 0 (
        echo ❌ CI FAILING - Some checks have failed
        echo.
        echo Failed checks:
        gh pr checks %PR_NUMBER% | findstr /C:"fail"
        set ISSUES_FOUND=1
    ) else (
        gh pr checks %PR_NUMBER% | findstr /C:"pending" > nul
        if !ERRORLEVEL! equ 0 (
            echo ⏳ CI PENDING - Some checks are still running
            set ISSUES_FOUND=1
        ) else (
            echo ✅ All checks passing
        )
    )
) else (
    echo ⚠️  Could not fetch CI checks
)

echo.
echo ============================================================

if %ISSUES_FOUND% equ 0 (
    echo            ✅ READY TO MERGE ✅
    echo ============================================================
    echo.
    echo Next step: Merge the PR with 'gh pr merge %PR_NUMBER%'
) else (
    echo            ❌ BLOCKED - Action Required ❌
    echo ============================================================
    echo.
    echo Please resolve the issues above before merging.
)
echo.
