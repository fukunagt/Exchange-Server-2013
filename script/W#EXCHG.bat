rem ***************************************
rem *           W#EXCHG.BAT               *
rem *                                     *
rem * Title : Exchange Setting Option for Mailbox    *
rem * Date : 2008.06.23                   *
rem * Version : 2.0                       *
rem ***************************************

rem ------------------------------------------
rem Parameters
rem W#EXCHG1 : Domain
rem W#EXCHG1 : Domain User Account
rem W#EXCHG3 : Organization
rem W#EXCHG4 : Administrative Group
rem W#EXCHG5 : Mailbox
rem W#EXCHG6 : Public Folder


rem W#EXCHG9 : Log output using ARMLOG command
rem            0: Disable
rem            1: Enable
rem ------------------------------------------

SET W#EXCHG1=ws2012-31dom
SET W#EXCHG2=%W#EXCHG1%Administrator
SET W#EXCHG3=First Organization
SET W#EXCHG4=Exchange Administrative Group (FYDIBOHF23SPDLT)
SET W#EXCHG5=DB01
SET W#EXCHG9=1



