:: ========================================================================== ::
:: Authors:
:: - Tancredi-Paul Grozav <paul@grozav.info>
:: ========================================================================== ::
:: @echo off
set timeout_duration=5
:: ========================================================================== ::
echo Hello world!
:: timeout /t %timeout_duration% >nul
Powershell.exe -executionpolicy remotesigned -File  D:\windows_setup.ps1
:: ========================================================================== ::
