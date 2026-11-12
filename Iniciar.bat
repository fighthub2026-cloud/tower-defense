@echo off
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
 echo Instale o Node.js 20 ou superior em https://nodejs.org e tente novamente.
 pause
 exit /b 1
)
node tools/server.mjs --open
if errorlevel 1 pause
