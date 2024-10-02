### Get all deleted sites

```powershell
Get-SPODeletedSite -IncludeOnlyPersonalSite | fl url
```

### Restore deleted site

```powershell
Restore-SPODeletedSite -Identity <url>
```

### Set owner on restored site

```powershell
Set-SPOUser -Site <url> -LoginName <upn> -IsSiteCollectionAdmin $true
```

### Removing restored site
```powershell
Remove-SPOSite -Identity <url>
```

[Extra info restore sites](https://docs.microsoft.com/en-us/onedrive/restore-deleted-onedrive)