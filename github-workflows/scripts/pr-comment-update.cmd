@echo off
REM Update an existing comment on a PR
REM Usage: pr-comment-update.cmd <comment-id> <review|issue> "New body text"

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: pr-comment-update.cmd ^<comment-id^> ^<review^|issue^> "new body"
    exit /b 1
)
if "%~2"=="" (
    echo Usage: pr-comment-update.cmd ^<comment-id^> ^<review^|issue^> "new body"
    exit /b 1
)
if "%~3"=="" (
    echo Usage: pr-comment-update.cmd ^<comment-id^> ^<review^|issue^> "new body"
    exit /b 1
)

set COMMENT_ID=%~1
set COMMENT_TYPE=%~2
set NEW_BODY=%~3

if "%COMMENT_TYPE%"=="issue" (
    gh api "repos/{owner}/{repo}/issues/comments/%COMMENT_ID%" -X PATCH -f body="%NEW_BODY%" --jq "{id, updated: true}"
) else (
    gh api "repos/{owner}/{repo}/pulls/comments/%COMMENT_ID%" -X PATCH -f body="%NEW_BODY%" --jq "{id, updated: true}"
)

echo Comment %COMMENT_ID% updated
