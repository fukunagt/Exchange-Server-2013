#
# Control a mailbox database 
#

# Set error codes
$ErrorConnectExchangeServer = 30
$ErrorGetMailboxDatabase    = 31
$ErrorMountDatabase         = 32
$ErrorDismountDatabase      = 33
$ErrorWrongControlCode      = 39

# Set my script name
$MyName = $MyInvocation.MyCommand.Name
Write-Output "$MyName (PID:$PID) : Started."

# Connect to Exchange Server
Connect-ExchangeServer -Auto
$bRet = $?
if ($bRet -eq $False)
{
        clplogcmd -m "$MyName : Connect-ExchangeServer failed." -i $ErrorConnectExchangeServer -l ERR 
}

# Mount/Dismount a mailbox database
if ($env:DatabaseControl -eq "Mount") 
{
        Mount-Database -Identity $env:MailboxDatabaseName
        $bRet = $?
        if ($bRet -eq $False)
        {
                clplogcmd -m "$MyName : Mount-Database failed." -i $ErrorMountDatabase -l ERR
                exit $ErrorMountDatabase
        }
        Get-MailboxDatabase -Status -Identity $env:MailboxDatabaseName | Format-List -Property Name,ServerName,Mounted,MountedOnServer
}
elseif ($env:DatabaseControl -eq "Dismount") 
{
        Dismount-Database -Identity $env:MailboxDatabaseName -Confirm:$False
        $bRet = $?
        if ($bRet -eq $False)
        {
                clplogcmd -m "$MyName : Dismount-Database failed." -i $ErrorDismountDatabase -l ERR
                exit $ErrorDismountDatabase
        }
        Get-MailboxDatabase -Status -Identity $env:MailboxDatabaseName | Format-List -Property Name,ServerName,Mounted,MountedOnServer
}
else 
{
        clplogcmd -m "$MyName : Control code is wrong ($env:DatabaseControl)." -i $ErrorWrongControlCode -l ERR
        exit $ErrorWrongControlCode
}

Write-Output "$MyName : Completed successfully."
exit 0
