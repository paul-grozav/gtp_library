:: ========================================================================== ::
:: Authors:
:: - Tancredi-Paul Grozav <paul@grozav.info>
:: ========================================================================== ::
@echo off
set linux_win_data_path=/mnt
if exist D:\ (
  set win_data_path=D:
  set linux_win_data_path=%linux_win_data_path%/d
) else (
  set win_data_path=C:
  set linux_win_data_path=%linux_win_data_path%/c
)
set win_data_path=%win_data_path%\data
set settings_yml=%win_data_path%\my.yml
set result=
call :get_config result "%settings_yml%" ^
  "[\"domain\"][\"name\"]"
echo result: %result%
goto :EOF

:get_config
set result=%1
set yml_file=%~2
set obj_path=%~3
set "c="
set "c=%c%import yaml;"
:: Use raw string, to avoid complaining about "D:\data" unknown \d character:
:: <string>:1: SyntaxWarning: invalid escape sequence '\d'
set "c=%c%file = open(r\"%yml_file%\", \"r\");"
set "c=%c%config = yaml.safe_load(file);"
set "c=%c%print(config%obj_path%);"
for /f "tokens=* usebackq" %%f in (`python3 -c "%c%"`) do (set %result%=%%f)
goto :EOF

:EOF
:: ========================================================================== ::
:: Have a file like: D:\data\my.yml
:: domain:
::   name: SomeThing
:: ========================================================================== ::
