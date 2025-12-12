<#
	.DESCRIPTION
	This script will clean up all the folders and libraries based on the data in the CSV file.
	
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
			If ($Site.Migrated -eq "Yes") # If the site is migrated, then clean
			{
				Try
				{
					Connect-PnPOnline $Site.Src_Url -ClientId $Azure_SP_AppID -Interactive
				}
				Catch
				{
					Write-Host "Cannot connect: $($Site.Src_Url)" -ForegroundColor Red
					Throw
				}

				If ($Site.Src_Subfolder) # If there is a subfolder in the CSV file
				{
					Try
					{
						$Location = "$($Site.Src_Url)/$($Site.Src_Lib)/$($Site.Src_Folder)/$($Site.Src_Subfolder)"

						Remove-PnPFolder -Name "$($Site.Src_Folder)/$($Site.Src_Subfolder)" -Folder $Site.Src_Lib -Force
						Write-Host "Removed: $Location" -ForegroundColor Green
					}
					Catch
					{
						Write-Host "Not found: $Location" -ForegroundColor Yellow
					}
				}
				ElseIf ($Site.Src_Folder) # If there is a folder in the CSV file
				{
					Try
					{
						$Location = "$($Site.Src_Url)/$($Site.Src_Lib)/$($Site.Src_Folder)"

						Remove-PnPFolder -Name $Site.Src_Folder -Folder $Site.Src_Lib -Force
						Write-Host "Removed: $Location" -ForegroundColor Green
					}
					Catch
					{
						Write-Host "Not found: $Location" -ForegroundColor Yellow
					}
				}
				ElseIf ($Site.Src_Lib) # If there is a library in the CSV file
				{
					Try
					{
						$Location = "$($Site.Src_Url)/$($Site.Src_Lib)"

						Remove-PnPList -Identity $Site.Src_Lib -Force
						Write-Host "Removed: $Location" -ForegroundColor Green
					}
					Catch
					{
						Write-Host "Not found: $Location" -ForegroundColor Yellow
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