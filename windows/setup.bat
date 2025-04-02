:: ========================================================================== ::
:: Authors:
:: - Tancredi-Paul Grozav <paul@grozav.info>
:: ========================================================================== ::
:: # Recovery - set reboot in safemode
:: C:\windows\system32\bcdedit /set {default} safeboot minimal
:: # Remove set reboot in safemode
:: bcdedit /deletevalue {default} safeboot
:: ========================================================================== ::
:: @echo off
set timeout_duration=5
:: ========================================================================== ::
echo Hello world!
:: timeout /t %timeout_duration% >nul
Powershell.exe -executionpolicy remotesigned -File  D:\windows_setup.ps1
:: ========================================================================== ::
