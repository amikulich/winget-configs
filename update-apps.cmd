@echo off
rem Upgrades apps whitelisted in a winget config. Optional arg: path to config JSON.
rem Usage: update-apps.cmd [config.json]
if "%~1"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-apps.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-apps.ps1" -ConfigPath "%~1"
)
exit /b %ERRORLEVEL%
