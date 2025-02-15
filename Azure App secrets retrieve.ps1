<#
	.DESCRIPTION
	Check if there are any Azure App secrets that are about to expire.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies:
		- Certificate for connecting to Microsoft Graph
		- Microsoft.Graph PS module
		- M365:
			- App registration
			- API permissions: Application.Read.All
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

	# Get all secrets
	$Apps_Secrets = Get-MgApplication -All
	$Complete_List = @()

	# Todays date for comparison with the dates from the secrets
	$Date_Today = Get-Date

	# Loop through all apps that has a secret
	Foreach ($App_Secret in $Apps_Secrets)
	{
		# Loop through all the secrets
		Foreach ($Secret in ($App_Secret | select -ExpandProperty PasswordCredentials))
		{
			$End_Date = Get-Date $Secret.EndDateTime
			$Days = New-TimeSpan -Start $Date_Today -End $End_Date # How many days the secret is still valid
			
			$List = New-Object -TypeName PSObject
			$List | Add-Member -NotePropertyName ID -NotePropertyValue $Secret.keyId
			$List | Add-Member -NotePropertyName Name -NotePropertyValue $App_Secret.DisplayName
			$List | Add-Member -NotePropertyName AppID -NotePropertyValue $App_Secret.AppId
			$List | Add-Member -NotePropertyName Date -NotePropertyValue (Get-Date $End_Date -Format "dd-MM-yyyy")
			$List | Add-Member -NotePropertyName Days -NotePropertyValue $Days.Days
			$List | Add-Member -NotePropertyName Type -NotePropertyValue "Secret"

			$Complete_List += $List
		}
	}

	# Loop through all apps that has a certificate
	Foreach ($App_Cert in $Apps_Secrets)
	{
		# Loop through all the secrets
		Foreach ($Cert in ($App_Cert | select -ExpandProperty KeyCredentials))
		{
			$End_Date = Get-Date $Cert.EndDateTime
			$Days = New-TimeSpan -Start $Date_Today -End $End_Date # How many days the secret is still valid
			
			$List = New-Object -TypeName PSObject
			$List | Add-Member -NotePropertyName ID -NotePropertyValue $Cert.keyId
			$List | Add-Member -NotePropertyName Name -NotePropertyValue $App_Cert.DisplayName
			$List | Add-Member -NotePropertyName AppID -NotePropertyValue $App_Cert.AppId
			$List | Add-Member -NotePropertyName Date -NotePropertyValue (Get-Date $End_Date -Format "dd-MM-yyyy")
			$List | Add-Member -NotePropertyName Days -NotePropertyValue $Days.Days
			$List | Add-Member -NotePropertyName Type -NotePropertyValue "Certificate"

			$Complete_List += $List
		}
	}	

	Return $Complete_List | ConvertTo-Json
}
Else
{
	Write-Host "PowerShell module not installed: Microsoft.Graph" -ForegroundColor Red
}