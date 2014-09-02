#
# Check if all Exchange services are running
#

# Set error codes
$ErrorGetService =    10
$ErrorServiceStatus = 11

# Set my script name
$MyName = $MyInvocation.MyCommand.Name
Write-Output "$MyName (PID:$PID) : Started."

# Set service name for an array
$ExchangeServices = @(
<#
"HostControllerService",'
#>
"MSExchangeADTopology",
"MSExchangeAntispamUpdate",
"MSExchangeDagMgmt",
"MSExchangeDelivery",
"MSExchangeDiagnostics",
"MSExchangeEdgeSync",
"MSExchangeFastSearch",
"MSExchangeFrontEndTransport",
"MSExchangeHM",
<#
"MSExchangeImap4",
"MSExchangeIMAP4BE",
#>
"MSExchangeIS",
"MSExchangeMailboxAssistants",
"MSExchangeMailboxReplication",
<#
"MSExchangeMigrationWorkflow",
#>
<#
"MSExchangePop3",
"MSExchangePOP3BE",
#>
"MSExchangeRepl",
"MSExchangeRPC",
"MSExchangeServiceHost",
"MSExchangeSharedCache",
"MSExchangeSubmission",
"MSExchangeThrottling",
"MSExchangeTransport",
"MSExchangeTransportLogSearch",
"MSExchangeUM",
"MSExchangeUMCR",
"SearchExchangeTracing"
)

# Check if all Exchange services are running
Write-Output "Wait for all Exchange services to be running..."
<#
:checkService while($True)
#>
:checkService1 for ($i = 0; $i -lt $env:RetryCount; $i++)
{
        :checkService2 for ($j = 0; $j -lt $ExchangeServices.Count; $j++)
        {
                $ServiceName = $ExchangeServices[$j]
                $CurrentService = Get-Service -Name $ServiceName
                $bRet = $?
                if ($bRet -eq $False)
                {
                        clplogcmd -m "Get-Service failed." -i $ErrorGetService -l ERR
                        break checkService2
                }
                $DisplayName = $CurrentService.DisplayName
                $Status = $CurrentService.Status
                if ($Status -eq "Running")
                {
<# DEBUG
                        Write-Output "$DisplayName : $Status (retry:$i)"
#>
                }
                else
                {
                        Write-Output "$DisplayName : $Status (retry:$i)"
                        Write-Output "Wait for $DisplayName to be running."
                        break checkService2
                }
        }
        if ($j -eq $ExchangeServices.Count)
        {
                Write-Output "All Exchange services are running."
                break checkService1
        }
        armsleep $env:RetryInterval
}
if ($i -eq $env:RetryCount)
{
        clplogcmd -m "Some Exchange services are not running." -i $ErrorServiceStatus -l ERR
}
else
{
        Write-Output "$MyName (PID:$PID): Completed successfully."
        exit 0
}

# Start up Exchange services
:startService1 for ($i = 0; $i -lt $env:RetryCount; $i++)
{
        :startService2 for ($j = 0; $j -lt $ExchangeServices.Count; $j++)
        {
                $ServiceName = $ExchangeServices[$j]
                $CurrentService = Get-Service -Name $ServiceName
                $bRet = $?
                if ($bRet -eq $False)
                {
                        clplogcmd -m "Get-Service failed." -i $ErrorGetService -l ERR
                        break startService2
                }
                $DisplayName = $CurrentService.DisplayName
                $Status = $CurrentService.Status
                if ($Status -eq "Stopped")
                {
                        Write-Output "$DisplayName : $Status (retry:$i)."
                        Write-Output "Start $DisplayName."
                        Start-Service -Name $ServiceName
                        break startService2
                }
                elseif ($Status -eq "Running")
                {
<# DEBUG
                        Write-Output "$DisplayName : $Status (retry:$i)"
#>
                }
                else
                {
                        Write-Output "$DisplayName : $Status (retry:$i)"
                        break startService2
                }
        }
        if ($j -eq $ExchangeServices.Count)
        {
                Write-Output "All Exchange services are running."
                break startService1
        }
        armsleep $env:RetryInterval
}

Write-Output "$MyName (PID:$PID): Completed successfully."
exit 0
