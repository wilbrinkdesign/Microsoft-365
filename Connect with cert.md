1. [Create self-signed certificate](https://learn.microsoft.com/en-us/sharepoint/dev/solution-guidance/security-apponly-azuread)

```powershell
.\Create-SelfSignedCertificate.ps1 -CommonName "<dns>" -StartDate 2030-10-01 -EndDate 2031-10-01
```

2. Then create Azure App registration: https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps
3. Then connect with PowerShell to the Azure App: Connect-PnPOnline -ClientId <app_id> -Url "<sharepoint_url>" -Tenant tenant.onmicrosoft.com -Thumbprint <cert_thumbprint>