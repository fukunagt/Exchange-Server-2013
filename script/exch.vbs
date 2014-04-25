'===============================================================
' Purpose:      Execute all tasks required to failover Exchange server
' Authors:      Gary Pope and Jennifer Ricketts
' Date:         FIXME
'===============================================================

Option explicit
'On Error Resume Next
Err.number = 0


'===============================================================
' Variables and Constants
'===============================================================

' Declare variables
Dim objConnection
Dim objRootDSE
Dim strAdminGrp
Dim strDNSDomain
Dim strExchMDBCopy
Dim strExchMDBCopyClass
Dim strHostname
Dim strMBStore
Dim strOrg

' Set variables
strExchMDBCopyClass = "msExchMDBCopy"

' Check arguments
If WScript.Arguments.Count <> 4 Then
    WScript.Echo "Invalid parameters."
    WScript.Quit
End If

' Insert arguments into variables
strHostname = WScript.Arguments(0)
strOrg = WScript.Arguments(1)
strAdminGrp = WScript.Arguments(2)
strMBStore = WScript.Arguments(3)

' Show variables
WScript.Echo "<<Parameters set by user>>"
WScript.Echo "Computer Name                              : " & strHostname
WScript.Echo "Organization                               : " & strOrg
WScript.Echo "Administrative Group                       : " & strAdminGrp
WScript.Echo "Mailbox Database                           : " & strMBStore
WScript.Echo ""

' Binding to Active Directory
Set objRootDSE = GetObject("LDAP://RootDSE")
strDNSDomain = objRootDSE.Get("DefaultNamingContext")
Call ErrorCheck("Error while binding to AD.")

' ADODB Connect
Set objConnection = CreateObject("ADODB.Connection")
objConnection.Provider = "ADSDSOObject"
objConnection.Open "ADs Provider"
Call ErrorCheck("Error while connecting to ADODB.")

' Get strExchMDBCopy
strExchMDBCopy = GetExchMDBCopy()
WScript.Echo "msExchMDBCopy                              : " & strExchMDBCopy

' FIXME: I don't like following function name. I would like to rename it.
' Change some paramaters
Call ChangeServer()

WScript.Quit



'###############################################################
' Function procedures
'###############################################################
'===============================================================
' Get object name
'===============================================================
Function GetObjectName (DNSDomainName, Attribute)
    Dim objMatch
    Dim objVar
    Dim strLDAP

    strLDAP = "<LDAP://CN=Configuration," & DNSDomainName &_
              ">;(&(objectClass=" & Attribute &_
              "));adspath;subtree"
    Set objMatch = objConnection.Execute(strLDAP)
    Set objVar = GetObject(objMatch.Fields(0).Value)
    GetObjectName = objVar.cn
End Function


'===============================================================
' Get msExchMDBCopy of Mailbox
'===============================================================
Function GetExchMDBCopy()
    Dim objMatch
    Dim objVar
    Dim strLDAP

    strLDAP = "<LDAP://CN=" & strMBStore &_
              ",CN=Databases" &_
              ",CN=" & strAdminGrp &_
              ",CN=Administrative Groups" &_
              ",CN=" & strOrg &_
              ",CN=Microsoft Exchange" &_
              ",CN=Services" &_
              ",CN=Configuration" &_
              "," & strDNSDomain &_
              ">;(&(objectClass=msExchMDBCopy));adspath;subtree"

    Set objMatch = objConnection.Execute(strLDAP)
    Set objVar = GetObject(objMatch.Fields(0).Value)
    GetExchMDBCopy = objVar.cn
End Function


'===============================================================
' Get msExchMDBCopy of Mailbox
'===============================================================
Function ChangeServer()
    Dim objBase
    Dim objExec
    Dim objShell
    Dim objNew
    Dim strLegacyExchangeDN
    Dim strNewServer
    Dim strCmd

    set objBase = GetObject("LDAP://CN=" & strMBStore &_
                            ",CN=Databases" &_
                            ",CN=" & strAdminGrp &_
                            ",CN=Administrative Groups" &_
                            ",CN=" & strOrg &_
                            ",CN=Microsoft Exchange" &_
                            ",CN=Services" &_
                            ",CN=Configuration" &_
                            "," & strDNSDomain)

    strNewServer = "CN=" & strHostname &_
                   ",CN=Servers" &_
                   ",CN=" & strAdminGrp &_
                   ",CN=Administrative Groups" &_
                   ",CN=" & strOrg &_
                   ",CN=Microsoft Exchange" &_
                   ",CN=Services" &_
                   ",CN=Configuration" &_
                   "," & strDNSDomain

    strLegacyExchangeDN = "/o=" & strOrg &_
                          "/ou=" & strAdminGrp &_
                          "/cn=Configuration" &_
                          "/cn=Servers" &_
                          "/cn=" & strHostname &_
                          "/cn=Microsoft Private MDB"

    ' Changing Mailbox owning server
    WScript.Echo "msExchOwningServer (old)                   : " & objBase.msExchOwningServer
    objBase.msExchOwningServer = strNewServer
    objBase.SetInfo
    WScript.Echo "msExchOwningServer (new)                   : " & objBase.msExchOwningServer

    ' Changing MailBox Master Server
    WScript.Echo "msExchMasterServerOrAvailabilityGroup (old): " & objBase.msExchMasterServerOrAvailabilityGroup
    objBase.msExchMasterServerOrAvailabilityGroup = strNewServer
    objBase.SetInfo
    WScript.echo "msExchMasterServerOrAvailabilityGroup (new): " & objBase.msExchMasterServerOrAvailabilityGroup    

    ' Changing MailBox Legacy Server
    WScript.Echo "legacyExchangeDN (old)                     : " & objBase.legacyExchangeDN
    objBase.legacyExchangeDN = strLegacyExchangeDN
    objBase.SetInfo
    WScript.echo "legacyExchangeDN (new)                     : " & objBase.legacyExchangeDN


    ' Copy from ChangeHostServer
    set objBase = GetObject("LDAP://CN=" & strExchMDBCopy &_
                            ",CN=" & strMBStore &_
                            ",CN=Databases" &_ 
                            ",CN=" & strAdminGrp &_
                            ",CN=Administrative Groups" &_
                            ",CN=" & strOrg &_
                            ",CN=Microsoft Exchange" &_
                            ",CN=Services" &_
                            ",CN=Configuration" &_
                            "," & strDNSDomain)

    WScript.Echo "msExchHostServerLink (old)                 : " & objBase.msExchHostServerLink
    objBase.msExchHostServerLink = strNewServer
    objBase.SetInfo
    WScript.Echo "msExchHostServerLink (new)                 : " & objBase.msExchHostServerLink


    ' Change DN using dsmove command
    WScript.Echo "distinguishedName (old)                    : " & objBase.distinguishedName
    WScript.Echo "objBase.cn                                 : " & objBase.cn
    WScript.Echo "objBase.name                               : " & objBase.name

    ' FIXME: The following line does not work well ... :(
    ' FIXME: Are there any good ways to change CN of strExchMDBCopy?
    strCmd = "dsmove" & " " & """" & objBase.distinguishedName & """" & "-newname" & " " & """" & strHostname & """"
    WScript.Echo strCmd
    Set objShell = CreateObject("WScript.Shell")
    Set objExec = objShell.Exec(strCmd)
'    WScsrip.Echo objExec.StdOut.ReadAll

    WScript.Echo "distinguishedName (new)                    : " & objBase.distinguishedName

End Function



'###############################################################
' Sub procedures
'###############################################################
' Error handling
Sub ErrorCheck(strError)
    If Err.Number <> 0 Then
	Wscript.Echo strError & vbCrLf _
            & "Error number: " & Err.Number & " " & VbCrLf _
            & "Error source: " & Err.Source & " " & vbCrLf _
            & "Error description: " & Err.Description & vbCrLf _
            & VbCrLf & "Cancelling script now."
	Err.Clear
	Wscript.Quit
    End If
End Sub
