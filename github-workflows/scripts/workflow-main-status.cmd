@echo off
REM Show workflow status for main branch (auto-detects default)
REM Usage: workflow-main-status.cmd [branch] [workflow-name]

setlocal enabledelayedexpansion

set BRANCH=%~1
if "%BRANCH%"=="" (
    REM Auto-detect default branch
    for /f "tokens=*" %%a in ('gh repo view --json defaultBranchRef --jq ".defaultBranchRef.name" 2^>nul') do set BRANCH=%%a
)

REM Fallback if detection failed
if "%BRANCH%"=="" set BRANCH=main

set WORKFLOW=%~2

if "%WORKFLOW%"=="" (
    gh run list --branch %BRANCH% --limit 10
) else (
    gh run list --branch %BRANCH% --workflow "%WORKFLOW%" --limit 10
)
