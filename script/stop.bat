rem ***************************************
rem *              stop.bat               *
rem *                                     *
rem * title   : stop script file sample   *
rem ***************************************





rem ***************************************
rem Check startup attributes
rem ***************************************
IF "%CLP_EVENT%" == "START" GOTO NORMAL
IF "%CLP_EVENT%" == "FAILOVER" GOTO FAILOVER

rem Cluster Server is not started
GOTO no_arm





rem ***************************************
rem Process for normal quitting program
rem ***************************************
:NORMAL
:FAILOVER


rem Check Disk
IF "%CLP_DISK%" == "FAILURE" GOTO ERROR_DISK

cd %CLP_SCRIPT_PATH%
call conf_sys.bat

rem *************
rem Routine procedure
rem *************
PowerShell -command ". '%EXCHBIN%\RemoteExchange.ps1'; Connect-ExchangeServer -auto; .\DismountMailboxDatabase.ps1"


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
