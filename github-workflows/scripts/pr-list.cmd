@echo off
REM List open PRs in the repository
REM Usage: pr-list.cmd [--author <username>] [--label <label>]

setlocal enabledelayedexpansion

set ARGS=

:parse_args
if "%~1"=="" goto run
if "%~1"=="--author" (
    set ARGS=!ARGS! --author %~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--label" (
    set ARGS=!ARGS! --label %~2
    shift
    shift
    goto parse_args
)
shift
goto parse_args

:run
echo === Open Pull Requests ===
gh pr list --state open %ARGS% --json number,title,author,createdAt,headRefName --jq ".[] | \"#\" + (.number|tostring) + \" | \" + .author.login + \" | \" + .headRefName + \" | \" + .title[:50]"
