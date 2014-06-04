rem ***************************************
rem * start.bat                           *
rem *                                     *
rem ***************************************



rem ***************************************
rem Check startup attributes
rem ***************************************
if "%CLP_EVENT%" == "START" goto NORMAL
if "%CLP_EVENT%" == "FAILOVER" goto FAILOVER
if "%CLP_EVENT%" == "RECOVER" goto RECOVER

rem Cluster Server is not started
goto NO_ARM



rem ***************************************
rem Startup process
rem ***************************************
:NORMAL
:FAILOVER

rem Check Disk
if "%CLP_DISK%" == "FAILURE" goto ERROR_DISK

cd %CLP_SCRIPT_PATH%

call config.bat

rem === Change AD parameters =======
PowerShell .\ChangeADParameters.ps1 "'%ORGANIZATION%' '%ADMINISTRATIVE_GROUP%' '%MAILBOX%'"

rem === Mount a mailbox database ===
PowerShell -command ". '%EXCHBIN%\RemoteExchange.ps1'; Connect-ExchangeServer -auto; .\MountMailboxDatabase.ps1 '%MAILBOX%'"

goto EXIT



rem ***************************************
rem Recovery process
rem ***************************************
:RECOVER

rem *************
rem Recovery process after return to the cluster
rem *************

goto EXIT



rem ***************************************
rem Irregular process
rem ***************************************
rem Process for disk errors
:ERROR_DISK
rem FIXME
rem ARMBCAST /MSG "Failed to connect the switched disk partition" /A
goto EXIT

rem Cluster Server is not started
:NO_ARM
rem FIXME
rem ARMBCAST /MSG "Cluster Server is offline" /A



:EXIT
