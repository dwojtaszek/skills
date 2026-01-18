@echo off
REM Get workflow logs for a PR
REM Usage: workflow-pr-logs.cmd <pr-number> [job-name]

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: workflow-pr-logs.cmd ^<pr-number^> [job-name]
    exit /b 1
)

set PR_NUMBER=%~1
set JOB_NAME=%~2

for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json headRefName --jq ".headRefName"') do set BRANCH=%%a
for /f "tokens=*" %%a in ('gh run list --branch %BRANCH% --limit 1 --json databaseId --jq ".[0].databaseId"') do set RUN_ID=%%a

if "%RUN_ID%"=="" (
    echo No workflow runs found for PR #%PR_NUMBER%
    exit /b 1
)

if "%JOB_NAME%"=="" (
    gh run view %RUN_ID% --log
) else (
    gh run view %RUN_ID% --log --job "%JOB_NAME%"
)
