@echo off
title FiveM Performance Optimizer v3.0
color 0B

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Richiesta elevazione privilegi...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c \"%~0\"' -Verb RunAs"
    exit /b
)

chcp 65001 >nul
cd /d "%~dp0"

echo.
echo ========================================
echo  FiveM Performance Optimizer v3.0
echo ========================================
echo  Cartella: %cd%
echo ========================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0FiveM-Optimizer.ps1"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ========================================
    echo  ERRORE: codice %ERRORLEVEL%
    echo ========================================
    pause
    exit /b %ERRORLEVEL%
)
exit /b 0
