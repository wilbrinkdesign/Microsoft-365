### Add Editor permissions to a calendar

```powershell
Add-MailboxFolderPermission <user>:\calendar -User <admin> -AccessRights Editor
```

### Add Editor permissions to a calendar with the option to view private items

```powershell
Add-MailboxFolderPermission <mailbox>:\agenda -User <username_rechten> -AccessRights Editor -SharingPermissionFlags Delegate,CanViewPrivateItems
```
