<#
	.DESCRIPTION
	Check how many M365 licenses the tenant has.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies: 
		- Microsoft.Graph PS module
		- Certificate for connecting to a Azure App where we have permissions to read all the M365 licenses.

	.EXAMPLE
	PS> <script_name>.ps1 -Org <name> -CertificateThumbprint <thumbprint>
#>

Param(
	[Parameter(Mandatory=$True)][ValidateSet("<org1>", "<org2>")][string]$Org,
	[string]$CertificateThumbprint = ""
)

# If PS module Microsoft.Graph is installed, continue
If ((Get-Module -ListAvailable -Name Microsoft.Graph))
{
	# Connect to the Azure App within the tenant that has permissions to read all Azure Apps
	If ($Org -eq "<org1>")
	{
		$Tenant_ID = ""
		$App_ID = ""

		Connect-MgGraph -ClientId $App_ID -TenantId $Tenant_ID -CertificateThumbprint $CertificateThumbprint -NoWelcome
	}
	Elseif ($Org -eq "<org2>")
	{
		$Tenant_ID = ""
		$App_ID = ""

		Connect-MgGraph -ClientId $App_ID -TenantId $Tenant_ID -CertificateThumbprint $CertificateThumbprint -NoWelcome
	}

	# Get all M365 licenses
	$Licenses = Get-MgSubscribedSku | Where-Object SkuPartNumber -match "E3|E5|F1" | select -Property @{N='TotalUnits';E={$_.PrepaidUnits.Enabled}}, ConsumedUnits, SkuPartNumber
	$Complete_List = @()

	# Loop through all licenses
	Foreach ($License in $Licenses)
	{
		If ($License.TotalUnits -ne 0) # Only show licenses that are in use
		{
			$Remaining = [math]::Round($License.TotalUnits - $License.ConsumedUnits)
			$Warning = If ($License.SkuPartNumber -match "E5") { 50 } ElseIf ($License.SkuPartNumber -match "F1") { 10 } Else { 10 }

			$List = New-Object -TypeName PSObject
			$List | Add-Member -NotePropertyName Name -NotePropertyValue $License.SkuPartNumber
			$List | Add-Member -NotePropertyName Org -NotePropertyValue $Organisatie
			$List | Add-Member -NotePropertyName Total -NotePropertyValue $License.TotalUnits
			$List | Add-Member -NotePropertyName Used -NotePropertyValue $License.ConsumedUnits
			$List | Add-Member -NotePropertyName Remaining -NotePropertyValue $Remaining
			$List | Add-Member -NotePropertyName Warning -NotePropertyValue $Warning
			$List | Add-Member -NotePropertyName Date -NotePropertyValue (Get-Date)

			$Complete_List += $List
		}
	}

	Return $Complete_List | ConvertTo-Json
}
Else
{
	Write-Host "PowerShell module not installed: Microsoft.Graph" -ForegroundColor Red
}