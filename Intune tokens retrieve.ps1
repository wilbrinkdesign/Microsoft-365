<#
	.DESCRIPTION
	Check if there are any Intune certificates about to expire.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies: 
		- Microsoft.Graph PS module
		- Certificate for connecting to an Azure App where we have permissions to read the Intune environment.

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

	# Which kind of Intune certificates there are with an expiration date
	$Types_Certs = @("Push", "VPP", "DEP")
	$Complete_List = @()

	# Loop through all certificates
	Foreach ($Type in $Types_Certs)
	{
		If ($Type -eq "Push") # MDM Push Certificate
		{
			$Cert_Push = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/applePushNotificationCertificate" -Method GET
			$End_Date = Get-Date $Cert_Push.expirationDateTime
		}
		ElseIf ($Type -eq "VPP") # Intune VPP token
		{
			$Cert_VPP = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/vppTokens" -Method GET -OutputType PSObject | select -Expand value
			$End_Date = Get-Date $Cert_VPP.expirationDateTime
		}
		ElseIf ($Type -eq "DEP") # MDM Enrollment token certificate
		{
			$Cert_DEP = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings" -Method GET -OutputType PSObject | select -Expand value
			$End_Date = Get-Date $Cert_DEP.tokenExpirationDateTime
		}

		$Days = New-TimeSpan -Start (Get-Date) -End $End_Date # How many days the certificate is still valid
		
		$List = New-Object -TypeName PSObject
		$List | Add-Member -NotePropertyName Name -NotePropertyValue $Type
		$List | Add-Member -NotePropertyName Days -NotePropertyValue $Days.Days

		$Complete_List += $List
	}

	Return $Complete_List | ConvertTo-Json
}
Else
{
	Write-Host "PowerShell module not installed: Microsoft.Graph" -ForegroundColor Red
}