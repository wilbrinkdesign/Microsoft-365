<#
	.DESCRIPTION
	Check how many M365 licenses the tenant has.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies: 
		- Certificate for connecting to Microsoft Graph
		- Microsoft.Graph PS module
		- M365:
			- App registration
			- API permissions: Organization.Read.All
			- Upload certificate

	.EXAMPLE
	PS> <script_name>.ps1 -TenantID <id> -AppID <id> -CertificateThumbprint <thumbprint>
#>

Param(
	[Parameter(Mandatory=$True)][string]$TenantID,
	[Parameter(Mandatory=$True)][string]$AppID,
	[Parameter(Mandatory=$True)][string]$CertificateThumbprint
)

# If PS module Microsoft.Graph is installed, continue
If ((Get-Module -ListAvailable -Name Microsoft.Graph))
{
	# Connect to the Azure App within the tenant that has permissions to read all Azure Apps
	Connect-MgGraph -ClientId $AppID -TenantId $TenantID -CertificateThumbprint $CertificateThumbprint -NoWelcome
	
	# Get all M365 licenses
	$Licenses = Get-MgSubscribedSku | select -Property @{N='TotalUnits';E={$_.PrepaidUnits.Enabled}}, ConsumedUnits, SkuPartNumber

	# Loop through all licenses
	Foreach ($License in $Licenses)
	{
		If ($License.TotalUnits -ne 0) # Only show licenses that are in use
		{
			$Remaining = [math]::Round($License.TotalUnits - $License.ConsumedUnits)

			$List = New-Object -TypeName PSObject
			$List | Add-Member -NotePropertyName Name -NotePropertyValue $License.SkuPartNumber
			$List | Add-Member -NotePropertyName Total -NotePropertyValue $License.TotalUnits
			$List | Add-Member -NotePropertyName Used -NotePropertyValue $License.ConsumedUnits
			$List | Add-Member -NotePropertyName Remaining -NotePropertyValue $Remaining
			$List | Add-Member -NotePropertyName Date -NotePropertyValue (Get-Date)

			[array]$Complete_List += $List
		}
	}

	Return $Complete_List | ConvertTo-Json
}
Else
{
	Write-Host "PowerShell module not installed: Microsoft.Graph" -ForegroundColor Red
}