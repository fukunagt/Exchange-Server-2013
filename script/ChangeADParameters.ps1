#
# Change AD parameters for a mailbox database 
#

# FIXME: Check the argumetns

# Insert the arguments to the variables
$OrganizationName = $args[0]
$AdministrativeGroupName = $args[1]
$MailboxDatabaseName = $args[2]

# Get computer name
$ComputerName = $env:COMPUTERNAME
#$ComputerName = "WS2012-34"

# Get Active Directory name
$ActiveDirectoryName = (Get-ADDomain).DistinguishedName
# FIXME: Error handling

# Show the variables
Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Output "Organization              : $OrganizationName" 
Write-Output "Administrative Group      : $AdministrativeGroupName" 
Write-Output "Mailbox Database          : $MailboxDatabaseName" 
Write-Output "Computer Name             : $ComputerName"
Write-Output "Active Directory          : $ActiveDirectoryName"

# Set mailbox database distinguished name
$MailboxDatabaseDN = "CN=" + $MailboxDatabaseName +`
                     ",CN=Databases" +`
                     ",CN=" + $AdministrativeGroupName +`
                     ",CN=Administrative Groups" +`
                     ",CN=" + $OrganizationName +`
                     ",CN=Microsoft Exchange" +`
                     ",CN=Services" +`
                     ",CN=Configuration" +`
                     "," + $ActiveDirectoryName
Write-Output "MailboxDatabaseDN         : $MailboxDatabaseDN"

# Set server distinguished name
$ServerDN = "CN=" + $ComputerName +`
            ",CN=Servers" +`
            ",CN=" + $AdministrativeGroupName +`
            ",CN=Administrative Groups" +`
            ",CN=" + $OrganizationName +`
            ",CN=Microsoft Exchange" +`
            ",CN=Services" +`
            ",CN=Configuration" +`
            "," + $ActiveDirectoryName
Write-Output "ServerDN                  : $ServerDN"

# Set legacyExchangeDN
$ExchangeDN = "/o=" + $OrganizationName +`
              "/ou=" + $AdministrativeGroupName +`
              "/cn=Configuration" +`
              "/cn=Servers" +`
              "/cn=" + $ComputerName +` 
              "/cn=Microsoft Private MDB"
Write-Output "ExchangeDN                 : $ExchangeDN"
Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++"

# Get mailbox database object
$MailboxDatabaseObject = Get-ADObject -Identity $MailboxDatabaseDN -Properties *
# FIXME: Error handling

# Set local variables
$msExchMasterServerOrAvailabilityGroup = $MailboxDatabaseObject.msExchMasterServerOrAvailabilityGroup
$msExchOwningServer = $MailboxDatabaseObject.msExchOwningServer
$legacyExchangeDN = $MailboxDatabaseObject.legacyExchangeDN
Write-Output "msExchMasterServerOrAG (B): $msExchMasterServerOrAvailabilityGroup"
Write-Output "msExchOwningServer     (B): $msExchOwningServer"
Write-Output "legacyExchangeDN       (B): $legacyExchangeDN"

# Replace
Set-ADObject $MailboxDatabaseObject -Replace @{msExchMasterServerOrAvailabilityGroup="$ServerDN"}
# FIXME: Error handling
Set-ADObject $MailboxDatabaseObject -Replace @{msExchOwningServer="$ServerDN"}
# FIXME: Error handling
Set-ADObject $MailboxDatabaseObject -Replace @{legacyExchangeDN="$ExchangeDN"}
# FIXME: Error handling

# Check
$MailboxDatabaseObject = Get-ADObject -Identity $MailboxDatabaseDN -Properties *
# FIXME: Error handling

# Set local variables
$msExchMasterServerOrAvailabilityGroup = $MailboxDatabaseObject.msExchMasterServerOrAvailabilityGroup
$msExchOwningServer = $MailboxDatabaseObject.msExchOwningServer
$legacyExchangeDN = $MailboxDatabaseObject.legacyExchangeDN
Write-Output "msExchMasterServerOrAG (A): $msExchMasterServerOrAvailabilityGroup"
Write-Output "msExchOwningServer     (A): $msExchOwningServer"
Write-Output "legacyExchangeDN       (A): $legacyExchangeDN"


# Get msExchMDBcopy distinguished name
$msExchMDBcopyDN = Get-ADObject -Filter {(ObjectClass -Like "msExchMDBcopy")}`
                                -SearchBase $MailboxDatabaseDN
Write-Output "msExchMDBcopyDN (B)       : $msExchMDBcopyDN"

# Get 
$msExchMDBcopyObject = Get-ADObject -Identity $msExchMDBcopyDN -Properties *
$msExchHostServerLink = $msExchMDBcopyObject.msExchHostServerLink
Write-Output "msExchHostServerLink (B)  : $msExchHostServerLink"

# Replace
Set-ADObject -Identity $msExchMDBcopyObject -Replace @{msExchHostServerLink="$ServerDN"}

# Check 
$msExchMDBcopyObject = Get-ADObject -Identity $msExchMDBcopyDN -Properties *
$msExchHostServerLink = $msExchMDBcopyObject.msExchHostServerLink
Write-Output "msExchHostServerLink (A)  : $msExchHostServerLink"


Rename-ADObject -Identity "$msExchMDBcopyDN" -NewName "$ComputerName"
$msExchMDBcopyDN = Get-ADObject -Filter {(ObjectClass -Like "msExchMDBcopy")}`
                                -SearchBase $MailboxDatabaseDN
Write-Output "msExchMDBcopyDN (A)       : $msExchMDBcopyDN"

Write-Output "Done!"
Write-Output ""
