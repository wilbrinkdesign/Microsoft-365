$all_sites = Get-SPOSite -Limit All | ?{ $_.URL -like "https://sharepoint.com/sites/*" }

foreach ($site in $all_sites) 
{ 
    Set-SPOUser -Site $site.Url -LoginName s_account@test.onmicrosoft.com -IsSiteCollectionAdmin $true 
}