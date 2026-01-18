@echo off
REM Re-run a failed or all workflows for a PR
REM Usage: workflow-rerun.cmd <pr-number> [--failed]

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: workflow-rerun.cmd ^<pr-number^> [--failed]
    exit /b 1
)

set PR_NUMBER=%~1
set RERUN_TYPE=%~2
if "%RERUN_TYPE%"=="" set RERUN_TYPE=--failed

REM Get the branch name for the PR
for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json headRefName --jq ".headRefName"') do set BRANCH=%%a

REM Get the latest run ID
for /f "tokens=*" %%a in ('gh run list --branch %BRANCH% --limit 1 --json databaseId --jq ".[0].databaseId"') do set RUN_ID=%%a

if "%RUN_ID%"=="" (
    echo ❌ No workflow runs found for PR #%PR_NUMBER%
    exit /b 1
)

echo Re-running workflow %RUN_ID% for PR #%PR_NUMBER% (%RERUN_TYPE%)...

if "%RERUN_TYPE%"=="--failed" (
    gh run rerun %RUN_ID% --failed
) else (
    gh run rerun %RUN_ID%
)

if %ERRORLEVEL% equ 0 (
    echo ✅ Workflow re-run triggered
    gh run watch %RUN_ID%
) else (
    echo ❌ Failed to re-run workflow
    exit /b 1
)
