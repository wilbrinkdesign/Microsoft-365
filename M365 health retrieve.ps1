<#
	.DESCRIPTION
	Check the M365 overall health.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies: 
		- Microsoft.Graph PS module
		- Certificate for connecting to an Azure App where we have permissions to read all the M365 licenses.

	.LINK
	https://helloitsliam.com/2022/04/20/connect-to-microsoft-graph-powershell-using-an-app-registration/

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
	
	# Get M365 health
	$Health = Get-MgServiceAnnouncementIssue | Where-Object { $_.EndDateTime -eq $null -and $_.Classification -eq "incident" }
	$Complete_List = @()

	# Loop through all health issues
	Foreach ($Message in $Health)
	{
		$List = New-Object -TypeName PSObject
		$List | Add-Member -NotePropertyName ID -NotePropertyValue $Message.Id
		$List | Add-Member -NotePropertyName Title -NotePropertyValue $Message.Title

		$Complete_List += $List
	}

	Return $Complete_List | ConvertTo-Json
}
Else
{
	Write-Host "PowerShell module not installed: Microsoft.Graph" -ForegroundColor Red
}