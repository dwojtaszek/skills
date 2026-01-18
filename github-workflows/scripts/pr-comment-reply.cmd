@echo off
REM Reply to a PR (add a new comment)
REM Usage: pr-comment-reply.cmd <pr-number> "Your reply message"

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: pr-comment-reply.cmd ^<pr-number^> "message"
    exit /b 1
)
if "%~2"=="" (
    echo Usage: pr-comment-reply.cmd ^<pr-number^> "message"
    exit /b 1
)

set PR_NUMBER=%~1
set MESSAGE=%~2

gh pr comment %PR_NUMBER% --body "%MESSAGE%"
echo Comment posted to PR #%PR_NUMBER%
