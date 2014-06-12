## The purpose of the scripts
The scripts to create Exchange Server 2013 cluster with EXPRESSCLUSTER.

## The roles of each script
### start.bat
When you initiate to start a script resource, this bat file will be called.

### stop.bat
When you initiate to stop script resource, this bat file will be called.

### config.bat
It contains some parameters should be modified to match your environment.

### ChangeADParameters.ps1
It will be called by start.bat to change attributes of ADSI objects and containers as below.

*: This attribute will be primary/secondary server name.

     <Your Domain>
      |
      +-- Configuration
           |
           +-- Services
                |
                +-- Microsoft Exchange
                     |
                     +-- <Your Organization>
                          |
                          +-- Administrative Groups
                               |
                               +-- <Your Administrative Group>
                                    |
                                    +-- Databases
                                         |
                                         +-- <Your Mailbox Database>
                                              | * msExchMasterServerOrAvailabilityGroup
                                              | * msExchOwningServer
                                              | * legacyExchangeDN
                                              |
                                              +-- msExchMDBCopy (in right pane)
                                                   * cn
                                                   * distinguishedName
                                                   * msExchHostServerLink
                                                   * name

### MountMailboxDatabase.ps1
It will be called by start.bat to mount a mailbox database.

### DismountMailboxDatabase.ps1
It will be called by stop.bat to dismount a mailbox database.

