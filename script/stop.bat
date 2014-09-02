rem ***************************************
rem *              stop.bat               *
rem *                                     *
rem * title   : stop script file sample   *
rem ***************************************



rem ***************************************
rem Error codes
rem ***************************************
set EXITCODE=0
set ERROR_SD=1
set ERROR_CLUSTER=2



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

rem === Set Environment Variables ===
call SetEnvironment.bat

rem *************
rem Routine procedure
rem *************
set DatabaseControl=Dismount
PowerShell -File "%ExchangeBin%\RemoteExchange-ECX.ps1"
set EXITCODE=%ERRORLEVEL%
if %EXITCODE% neq 0 (
        clplogcmd -m "RemoteExchange-ECX.ps1 failed." -i %EXITCODE% -l ERR
        goto EXIT 
)

GOTO EXIT



rem ***************************************
rem Irregular process
rem ***************************************
rem Process for disk errors
:ERROR_DISK
clplogcmd -m "Failed to connect the shared disk." -i %ERROR_SD% -l ERR
set EXITCODE=%ERROR_SD%
goto EXIT

rem Cluster Server is not started
:NO_ARM
clplogcmd -m "Cluster Server is not running." -i %ERROR_CLUSTER% -l ERR
set EXITCODE=%ERROR_CLUSTER%



:EXIT
exit %EXITCODE%
