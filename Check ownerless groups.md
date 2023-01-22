### Get all Office 365 groups without a owner

```powershell
Get-UnifiedGroup | Where-Object { -Not $_.ManagedBy }
```

### Add a user to a Office 365 group as member and owner

```powershell
Add-UnifiedGroupLinks -Identity <team> -LinkType Members -Links <owner>
Add-UnifiedGroupLinks -Identity <team> -LinkType Owners -Links <owner>
```
