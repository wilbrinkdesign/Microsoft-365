<#
	.DESCRIPTION
	Check if there are any Intune certificates about to expire.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies: 
		- Microsoft.Graph PS module
		- Certificate for connecting to a Azure App where we have permissions to read the Intune environment.

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
			$Days = New-TimeSpan -Start (Get-Date) -End $End_Date # How many days the certificate is still valid
		}
		ElseIf ($Type -eq "VPP") # Intune VPP token
		{
			$Cert_VPP = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/vppTokens" -Method GET -OutputType PSObject | select -Expand value

			$End_Date = Get-Date $Cert_VPP.expirationDateTime
			$Days = New-TimeSpan -Start (Get-Date) -End $End_Date # How many days the certificate is still valid
		}
		ElseIf ($Type -eq "DEP") # MDM Enrollment token certificate
		{
			$Cert_DEP = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings" -Method GET -OutputType PSObject | select -Expand value

			$End_Date = Get-Date $Cert_DEP.tokenExpirationDateTime
			$Days = New-TimeSpan -Start (Get-Date) -End $End_Date # How many days the certificate is still valid
		}
		
		$List = New-Object -TypeName PSObject
		$List | Add-Member -NotePropertyName Naam -NotePropertyValue $Type
		$List | Add-Member -NotePropertyName Dagen -NotePropertyValue $Days.Days

		$Complete_List += $List
	}

	Return $Complete_List | ConvertTo-Json
}
Else
{
	Write-Host "PowerShell module not installed: Microsoft.Graph" -ForegroundColor Red
}