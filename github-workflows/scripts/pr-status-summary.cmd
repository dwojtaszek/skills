@echo off
REM Primary script: Show overall PR status summary
REM Usage: pr-status-summary.cmd <pr-number>

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: pr-status-summary.cmd ^<pr-number^>
    exit /b 1
)

set PR_NUMBER=%~1

echo === PR #%PR_NUMBER% Status Summary ===
echo.
echo ## PR Info

for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json title --jq ".title"') do echo Title: %%a
for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json state --jq ".state"') do echo State: %%a
for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json headRefName,baseRefName --jq ".headRefName + \" → \" + .baseRefName"') do echo Branch: %%a
for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json mergeable --jq ".mergeable"') do echo Mergeable: %%a

echo.
echo ## CI Checks
gh pr checks %PR_NUMBER%

echo.
echo ## Recent Workflow Runs
for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json headRefName --jq ".headRefName"') do set BRANCH=%%a
gh run list --branch %BRANCH% --limit 3
