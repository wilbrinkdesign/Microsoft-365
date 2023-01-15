Write-Host "De rechten worden nu ingesteld"
$all_sites = Get-SPOSite -Limit All | ?{ $_.URL -like "https://sharepoint.com/sites/*" }
foreach ($site in $all_sites) 
{ 
    Write-Host "s_account@test.onmicrosoft.com wordt nu 2e eigenaar van $($site.Url)"
    Set-SPOUser -Site $site.Url -LoginName s_account@test.onmicrosoft.com -IsSiteCollectionAdmin $true 
}