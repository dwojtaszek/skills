@echo off
REM Show workflow status for a PR
REM Usage: workflow-pr-status.cmd <pr-number> [workflow-name]

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: workflow-pr-status.cmd ^<pr-number^> [workflow-name]
    exit /b 1
)

set PR_NUMBER=%~1
set WORKFLOW=%~2

for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json headRefName --jq ".headRefName"') do set BRANCH=%%a

if "%WORKFLOW%"=="" (
    gh run list --branch %BRANCH% --limit 5
) else (
    gh run list --branch %BRANCH% --workflow "%WORKFLOW%" --limit 5
)
