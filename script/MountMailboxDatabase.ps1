#
# Mount a mailbox database 
#

# FIXME: Check the argumetns

# Insert the arguments to the variables
$MailboxDatabaseName = $args[0]

# Mount a mailbox database
Mount-Database -Identity $MailboxDatabaseName
