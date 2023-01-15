$opslag = (Get-SPOTenant).StorageQuota
$verbruikt = 0
$allesites = Get-SPOSite -Limit ALL | select StorageUsageCurrent
$allesites | %{ $verbruikt += $_.StorageUsageCurrent }
$verbruikt
$opslag / 1MB - $verbruikt / 1MB