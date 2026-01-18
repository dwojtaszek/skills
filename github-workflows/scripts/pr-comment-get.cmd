@echo off
REM Get a specific comment on a PR
REM Usage: pr-comment-get.cmd <pr-number> <comment-id> [review|issue]

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: pr-comment-get.cmd ^<pr-number^> ^<comment-id^> [review^|issue]
    exit /b 1
)
if "%~2"=="" (
    echo Usage: pr-comment-get.cmd ^<pr-number^> ^<comment-id^> [review^|issue]
    exit /b 1
)

set PR_NUMBER=%~1
set COMMENT_ID=%~2
set COMMENT_TYPE=%~3
if "%COMMENT_TYPE%"=="" set COMMENT_TYPE=review

if "%COMMENT_TYPE%"=="issue" (
    gh api "repos/{owner}/{repo}/issues/comments/%COMMENT_ID%" --jq "{id, type: \"issue\", body, created_at, user: .user.login}"
) else (
    gh api "repos/{owner}/{repo}/pulls/comments/%COMMENT_ID%" --jq "{id, type: \"review\", body, path, line, created_at, user: .user.login}"
)
