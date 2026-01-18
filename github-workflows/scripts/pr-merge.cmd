@echo off
REM Merge a PR (squash merge by default)
REM Usage: pr-merge.cmd <pr-number> [--rebase|--merge]

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: pr-merge.cmd ^<pr-number^> [--rebase^|--merge]
    exit /b 1
)

set PR_NUMBER=%~1
set MERGE_TYPE=%~2
if "%MERGE_TYPE%"=="" set MERGE_TYPE=--squash

echo Merging PR #%PR_NUMBER% with %MERGE_TYPE%...
gh pr merge %PR_NUMBER% %MERGE_TYPE% --delete-branch

if %ERRORLEVEL% equ 0 (
    echo ✅ PR #%PR_NUMBER% merged successfully
) else (
    echo ❌ Failed to merge PR #%PR_NUMBER%
    exit /b 1
)
