### Activate Shared Mailbox

```powershell
Enable-RemoteMailbox -Shared "<name>" -RemoteRoutingAddress <alias>@<org>.mail.onmicrosoft.com
```

### Check where a user has Full Access permissions on mailboxes

```powershell
Get-Mailbox -ResultSize unlimited | Get-MailboxPermission -User <user>
```

### Put a copy of the send message in the send items of the Shared Mailbox

```powershell
Set-Mailbox <naam> -MessageCopyForSendOnBehalfEnabled $True -MessageCopyForSentAsEnabled $True
```

### Hide from address list

```powershell
Set-RemoteMailbox <name> -HiddenFromAddressListsEnabled:$true
```
