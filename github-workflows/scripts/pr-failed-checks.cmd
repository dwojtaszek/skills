@echo off
REM Show only failed/pending checks for a PR
REM Usage: pr-failed-checks.cmd <pr-number>

if "%~1"=="" (
    echo Usage: pr-failed-checks.cmd ^<pr-number^>
    exit /b 1
)

set PR_NUMBER=%~1

echo === PR #%PR_NUMBER% Failed/Pending Checks ===
echo.
for /f "tokens=*" %%a in ('gh pr view %PR_NUMBER% --json title --jq ".title"') do echo PR: %%a
echo.

gh pr checks %PR_NUMBER% --json name,conclusion,detailsUrl --jq ".[] | select(.conclusion != \"SUCCESS\" and .conclusion != \"NEUTRAL\") | \"\(.name)\t\(.conclusion)\t\(.detailsUrl)\""
