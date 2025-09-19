@echo off
REM Wrapper for Wazuh to run the PowerShell script reliably
REM Pass "add" if no argument is provided
if "%1"=="" set ARG=add
if not "%1"=="" set ARG=%1

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0quarantine-host.ps1" %ARG%
exit /b %errorlevel%
