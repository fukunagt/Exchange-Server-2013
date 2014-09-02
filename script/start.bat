rem ***************************************
rem * start.bat                           *
rem *                                     *
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

rem === Set Environment Variables ===
call SetEnvironment.bat

rem === Check if all Exchange services are running ===
PowerShell .\CheckExchangeServices.ps1

rem === Change AD parameters =======
PowerShell .\ChangeADParameters.ps1
set EXITCODE=%ERRORLEVEL%
if %EXITCODE% neq 0 goto EXIT

rem === Mount a mailbox database ===
set DatabaseControl=Mount
PowerShell -File "%ExchangeBin%\RemoteExchange-ECX.ps1"
set EXITCODE=%ERRORLEVEL%
if %EXITCODE% neq 0 goto EXIT



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
clplogcmd -m "Failed to connect the shared disk." -i %ERROR_SD% -l ERR
set EXITCODE=%ERROR_SD%
goto EXIT

rem Cluster Server is not started
:NO_ARM
clplogcmd -m "Cluster Server is not running." -i %ERROR_CLUSTER% -l ERR
set EXITCODE=%ERROR_CLUSTER%



:EXIT
exit %EXITCODE%
