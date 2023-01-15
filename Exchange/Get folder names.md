### Get folder names calendar, inbox & send items from a mailbox

```powershell
$Email = (Get-Mailbox "<user>").UserPrincipalName
(($Email)+ ":\" + (Get-MailboxFolderStatistics $Email -FolderScope Calendar | Where-Object { $_.FolderType -eq "Calendar" }).Name)
(($email)+ ":\" + (Get-MailboxFolderStatistics $Email -FolderScope Inbox | Where-Object { $_.FolderType -eq "Inbox" }).Name)
(($email)+ ":\" + (Get-MailboxFolderStatistics $Email -FolderScope Sent | Where-Object { $_.FolderType -eq "SentItems" }).Name)
```