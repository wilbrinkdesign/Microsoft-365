### Check all licenses within the tenant

```powershell
Get-MsolAccountSku | Select AccountSkuId | Sort AccountSkuId
```

### Add license to all users

```powershell
Get-MsolUser -all | Where-Object {($_.licenses).accountskuid -like "*<tenant>:<license>*"} | Set-MsolUserLicense -AddLicenses "<tenant>:<license>"
```

### Disable license plan for specific user

```powershell
Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq "<license>"} | ForEach-Object {$_.ServiceStatus}
$x = New-MsolLicenseOptions -AccountSkuId "<tenant>:<license>" -DisabledPlans "<license>"
Get-MsolUser -UserPrincipalName <email> | Set-MsolUserLicense -LicenseOptions $x
```

### Get specific license from user

```powershell
Get-MsolUser -all | Where-Object {$_.userprincipalname -like "*<name>*" -and ($_.licenses).accountskuid -like "*<license>*"}
```

[Extra info about Microsoft 365 licenses](https://m365maps.com/)