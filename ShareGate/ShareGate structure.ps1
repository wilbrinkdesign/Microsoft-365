<#
	.DESCRIPTION
	This script will create the structure in SharePoint that is necessary for the migration based on the data in the CSV file.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies:
		- PnP.PowerShell PS module
		- CSV file

	.EXAMPLE
	PS> <script_name>.ps1 -CSV <csv_file>
#>

Param(
	[string]$CSV = ".\ShareGate.csv"
)

If (Test-Path $CSV)
{
	If ($PSVersionTable.PSVersion.Major -eq 7) # PowerShell 7 is mandatory
	{
		$CSV_File = $CSV
		$SharePoint_Module = "PnP.PowerShell"
		$Azure_SP_AppID = "" # Azure App to connect to SharePoint Online

		Try
		{
			Write-Host "Loading module: $SharePoint_Module" -ForegroundColor Yellow
			Import-Module $SharePoint_Module -DisableNameChecking -ErrorAction Stop
			Write-Host "Module loaded: $SharePoint_Module" -ForegroundColor Green
		}
		Catch
		{
			Try
			{
				Write-Host "Install module: $SharePoint_Module" -ForegroundColor Yellow
				Install-Module $SharePoint_Module -Scope CurrentUser -Force -ErrorAction Stop
			}
			Catch
			{
				Write-Host "Start PowerShell and re-run this script." -ForegroundColor Yellow
				Break
			}
		}

		$CSV_Import = Import-Csv $CSV_File -Delimiter ";" -Encoding Default

		Foreach ($Site in $CSV_Import)
		{
			If ($Site.Migrated -ne "Yes") # If it has not been migrated yet, check every line
			{
				Try
				{
					Connect-PnPOnline $Site.Dst_Url -ClientId $Azure_SP_AppID -Interactive
				}
				Catch
				{
					Write-Host "Cannot connect: $($Site.Dst_Url)" -ForegroundColor Red
					Throw
				}

				If ($Site.Dst_Lib) # If there is a library in the CSV file
				{
					Try
					{
						$Location = "$($Site.Dst_Url)/$($Site.Dst_Lib)"

						New-PnPList -Title $Site.Dst_Lib -Template DocumentLibrary -OnQuickLaunch
						Write-Host "Created: $Location" -ForegroundColor Green
					}
					Catch
					{
						Write-Host "Already exists or not found: $Location" -ForegroundColor Yellow
					}
				}

				If ($Site.Dst_Folder) # If there is a folder in the CSV file
				{
					Try
					{
						$Location = "$($Site.Dst_Url)/$($Site.Dst_Lib)/$($Site.Dst_Folder)"

						Add-PnPFolder -Name $Site.Dst_Folder -Folder $Site.Dst_Lib
						Write-Host "Created: $Location" -ForegroundColor Green
					}
					Catch
					{
						Write-Host "Already exists or not found: $Location" -ForegroundColor Yellow
					}
				}

				If ($Site.Dst_Subfolder) # If there is a subfolder in the CSV file
				{
					Try
					{
						$Location = "$($Site.Dst_Url)/$($Site.Dst_Lib)/$($Site.Dst_Folder)/$($Site.Dst_Subfolder)"

						Add-PnPFolder -Name $Site.Dst_Subfolder -Folder "$($Site.Dst_Lib)/$($Site.Dst_Folder)"
						Write-Host "Created: $Location" -ForegroundColor Green
					}
					Catch
					{
						Write-Host "Already exists or not found: $Location" -ForegroundColor Yellow
					}
				}
			}
		}
	}
	Else
	{
		Write-Host "Start this script with PowerShell 7." -ForegroundColor Yellow
	}
}
Else
{
	Write-Host "Not found: $CSV" -ForegroundColor Red
}