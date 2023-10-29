### Get all installed modules

```powershell
Get-InstalledModule
```

### SharePoint Online

```powershell
Install-Module Microsoft.Online.SharePoint.PowerShell
Update-Module Microsoft.Online.SharePoint.PowerShell

Connect-SPOService -Url <url>
Connect-PnPOnline -Url <url> -UseWebLogin -WarningAction 0
```

### Azure Online

```powershell
Install-Module MSOnline
Update-Module MSOnline
Install-Module AzureAD
Update-Module AzureAD

Connect-MsolService
Connect-AzureAD
```

### Exchange Online

```powershell
Install-Module PowershellGet
Install-Module ExchangeOnlineManagement
Update-Module ExchangeOnlineManagement

Connect-ExchangeOnline <upn> -ShowBanner:$False
```

### Teams Online

```powershell
Install-Module MicrosoftTeams
Install-Module MicrosoftTeams -Repository PSGallery
Update-Module MicrosoftTeams

Connect-MicrosoftTeams
```

### AD

```powershell
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online # Windows Clients
Install-WindowsFeature RSAT-AD-PowerShell # Windows Servers
Import-Module ActiveDirectory
```

### Microsoft Graph

```powershell
Install-Module -Name Microsoft.Graph
Update-Module -Name Microsoft.Graph

Connect-MSGraph
```

### Intune

```powershell
Install-Module -Name Microsoft.Graph.Intune
Update-Module -Name Microsoft.Graph.Intune

Connect-MSGraph
```