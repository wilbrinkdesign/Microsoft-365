### Get devices

```powershell
Get-MsolDevice -All | where { $_.ApproximateLastLogonTimestamp -like "*2018*" } | select-object -Property Enabled, DeviceId, DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp | export-csv C:\temp\stal
```

### Delete devices

```powershell
Get-MsolDevice -All | where { $_.ApproximateLastLogonTimestamp -like "*2018*" -and $_.enabled -eq $False } | Remove-MsolDevice -Force
```