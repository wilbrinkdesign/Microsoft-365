<#
	.DESCRIPTION
	Check the M365 overall health.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies: 
		- Microsoft.Graph PS module
		- M365:
			- App registration
			- API permissions: ServiceHealth.Read.All
			- Secret for connecting to Microsoft Graph
		- System environment variable 'M365_Secret' with the secret as plain text

	.EXAMPLE
	PS> <script_name>.ps1 -TenantID <id> -AppID <id>
#>

Param(
	[Parameter(Mandatory=$True)][string]$TenantID,
	[Parameter(Mandatory=$True)][string]$AppID,
	[string]$ClientSecret = [System.Environment]::GetEnvironmentVariable("M365_Secret", "Machine")
)

# If PS module Microsoft.Graph is installed, continue
If ((Get-Module -ListAvailable -Name Microsoft.Graph))
{
	If ($ClientSecret)
	{
		# Convert secret
		$Secret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
		$Client_Secret_Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AppID, $Secret

		# Connect to the Azure App within the tenant that has permissions to read all Azure Apps
		Connect-MgGraph -TenantId $TenantID -ClientSecretCredential $Client_Secret_Credential -NoWelcome
		
		# Get M365 health
		$Health = Get-MgServiceAnnouncementIssue | Where-Object { $_.EndDateTime -eq $null -and $_.Classification -eq "incident" }

		# Loop through all health issues
		Foreach ($Message in $Health)
		{
			$List = New-Object -TypeName PSObject
			$List | Add-Member -NotePropertyName ID -NotePropertyValue $Message.Id
			$List | Add-Member -NotePropertyName Title -NotePropertyValue $Message.Title

			[array]$Complete_List += $List
		}

		Return $Complete_List | ConvertTo-Json
	}
	Else
	{
		Write-Host "Secret is empty or environment var 'M365_Health_Secret' does not exist :(" -ForegroundColor Red	
	}
}
Else
{
	Write-Host "PowerShell module not installed: Microsoft.Graph" -ForegroundColor Red
}