rem ***************************************
rem *              start.bat              *
rem *                                     *
rem * title   : FIXME                     *
rem ***************************************





rem ***************************************
rem Check startup attributes
rem ***************************************
IF "%CLP_EVENT%" == "START" GOTO NORMAL
IF "%CLP_EVENT%" == "FAILOVER" GOTO FAILOVER
IF "%CLP_EVENT%" == "RECOVER" GOTO RECOVER

rem Cluster Server is not started
GOTO no_arm





rem ***************************************
rem Startup process
rem ***************************************
:NORMAL
:FAILOVER

rem Check Disk
IF "%CLP_DISK%" == "FAILURE" GOTO ERROR_DISK

rem ****
rem TODO:
rem ****
cd %CLP_SCRIPT_PATH%

call conf_sys.bat
call conf_mbx.bat

echo === Change AD parameters =======
PowerShell .\ChangeADParameters.ps1 "'%ORGANIZATION%' '%ADMINISTRATIVE_GROUP%' '%MAILBOX%'"

echo === Mount a mailbox database ===
PowerShell -command ". '%EXCHBIN%\RemoteExchange.ps1'; Connect-ExchangeServer -auto; .\MountMailboxDatabase.ps1"

GOTO EXIT


rem ***************************************
rem Recovery process
rem ***************************************
:RECOVER

rem *************
rem Recovery process after return to the cluster
rem *************

GOTO EXIT





rem ***************************************
rem Irregular process
rem ***************************************

rem Process for disk errors
:ERROR_DISK
ARMBCAST /MSG "Failed to connect the switched disk partition" /A
GOTO EXIT


rem Cluster Server is not started
:no_arm
ARMBCAST /MSG "Cluster Server is offline" /A





:EXIT
