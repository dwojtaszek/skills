@echo off
REM List all comments on a PR (both review and issue comments)
REM Usage: pr-comments-list.cmd <pr-number>

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: pr-comments-list.cmd ^<pr-number^>
    exit /b 1
)

set PR_NUMBER=%~1

echo === Review Comments (inline on code) ===
gh api "repos/{owner}/{repo}/pulls/%PR_NUMBER%/comments" --jq ".[] | \"\(.id) | review | \(.created_at) | \(.user.login) | \(.path):\(.line // \"N/A\") | \(.body[:80])\""
if %ERRORLEVEL% neq 0 echo (none)

echo.
echo === Issue Comments (general PR discussion) ===
gh api "repos/{owner}/{repo}/issues/%PR_NUMBER%/comments" --jq ".[] | \"\(.id) | issue | \(.created_at) | \(.user.login) | \(.body[:80])\""
if %ERRORLEVEL% neq 0 echo (none)
