@echo off
call conf_sys.bat
call conf_mbx.bat

echo === Change AD parameters =======
PowerShell .\ChangeADParameters.ps1 "'%ORGANIZATION%' '%ADMINISTRATIVE_GROUP%' '%MAILBOX%'"

echo === Mount a mailbox database ===
rem PowerShell -command ". '%EXCHBIN%\RemoteExchange.ps1'; Connect-ExchangeServer -auto; %SCRIPTPATH%\MountMailboxDatabase.ps1"