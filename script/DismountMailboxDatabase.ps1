#
# Dismount a mailbox database 
#

# FIXME: Check the argumetns

# Insert the arguments to the variables
$MailboxDatabaseName = $args[0]

# Dismount a mailbox database
Dismount-Database -Identity $MailboxDatabaseName -Confirm:$False
