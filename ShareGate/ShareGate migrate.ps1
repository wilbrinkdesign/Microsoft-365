<#
	.DESCRIPTION
	This script will copy all SharePoint files from one site to another based on the data in the CSV file.
	
	.NOTES
	Author: Mark Wilbrink
	Date: see Git info

	Dependencies:
		- ShareGate software
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
	If ($PSVersionTable.PSVersion.Major -eq 5) # PowerShell 5 is mandatory
	{
		$CSV_File = $CSV

		# Because the ShareGate PowerShell needs to be loaded 2 times. Buggy shit :)
		Do
		{
			Try
			{
				Import-Module "C:\Program Files (x86)\Sharegate\ShareGate\Sharegate.psd1" -ErrorAction Stop
			}
			Catch
			{
				Write-Host "Error during loading ShareGate PowerShell module." -ForegroundColor Red
			}

			Write-Host "ShareGate PowerShell loaded." -ForegroundColor Green
		} While ($? -eq $False)

		$Copy_Settings = New-CopySettings -OnContentItemExists IncrementalUpdate

		$CSV_Import = Import-Csv $CSV_File -Delimiter ";" -Encoding Default

		Try
		{
			If (!$Credentials) # If credentials var is empty, authenticate
			{
				$global:Credentials = Connect-Site -Url $CSV_Import[0].Src_Url -Browser # Grab the first URL en authenticate and use these credentials for future sites
			}
		}
		Catch
		{
			Write-Host "Cannot connect: $($CSV_Import[0].Src_Url)" -ForegroundColor Red
			Throw
		}

		Foreach ($Site in $CSV_Import)
		{
			If ($Site.Migrated -ne "Yes") # If it has not been migrated, check the line and copy!
			{
				Try
				{
					$Site_Source = Connect-Site -Url $Site.Src_Url -UseCredentialsFrom $Credentials
					Write-Host "Connected: $($Site.Src_Url)" -ForegroundColor Green
					$Site_Destination = Connect-Site -Url $Site.Dst_Url -UseCredentialsFrom $Credentials
					Write-Host "Connected: $($Site.Dst_Url)" -ForegroundColor Green
				}
				Catch
				{
					Write-Host "Cannot connect: $($Site.Src_Url) / $($Site.Dst_Url)" -ForegroundColor Red
				}

				$Src_Lib = Get-List -Name $Site.Src_Lib -Site $Site_Source
				$Dst_Lib = Get-List -Name $Site.Dst_Lib -Site $Site_Destination

				If ($Site.Src_Subfolder) # If there is a subfolder in the CSV file, only grab this one
				{
					Try
					{
						$Src_Path = "$($Site.Src_Url)/$($Site.Src_Lib)/$($Site.Src_Folder)/$($Site.Src_Subfolder)"

						If ($Site.Dst_Subfolder) # Subfolder needs to be copied to another subfolder
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)/$($Site.Dst_Folder)/$($Site.Dst_Subfolder)"
							Write-Host "Copy subfolder '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -SourceFolder "$($Site.Src_Folder)/$($Site.Src_Subfolder)" -DestinationFolder "$($Site.Dst_Folder)/$($Site.Dst_Subfolder)" -CopySettings $Copy_Settings
							Write-Host "Subfolder '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}
						ElseIf ($Site.Dst_Folder) # Subfolder needs to be copied to a folder
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)/$($Site.Dst_Folder)"
							Write-Host "Copy subfolder '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -SourceFolder "$($Site.Src_Folder)/$($Site.Src_Subfolder)" -DestinationFolder $($Site.Dst_Folder) -CopySettings $Copy_Settings
							Write-Host "Subfolder '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}
						Else # Subfolder needs to be copied to a library
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)"
							Write-Host "Copy subfolder '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -SourceFolder "$($Site.Src_Folder)/$($Site.Src_Subfolder)" -CopySettings $Copy_Settings
							Write-Host "Subfolder '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}

						$Site.Migrated = "Yes" # Adjust the state in the CSV file so we know what was migrated succesfully
					}
					Catch
					{
						Write-Host "'$Src_Path' or '$Dst_Path' not found." -ForegroundColor Red
						$Site.Migrated = "No" # Adjust the state in the CSV file so we know what was migrated succesfully
					}
				}
				ElseIf ($Site.Src_Folder) # If there is a folder in the CSV file, only grab this one
				{
					Try
					{
						$Src_Path = "$($Site.Src_Url)/$($Site.Src_Lib)/$($Site.Src_Folder)"

						If ($Site.Dst_Subfolder) # Folder needs to be copied to a subfolder
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)/$($Site.Dst_Folder)/$($Site.Dst_Subfolder)"
							Write-Host "Copy folder '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -SourceFolder "$($Site.Src_Folder)" -DestinationFolder "$($Site.Dst_Folder)/$($Site.Dst_Subfolder)" -CopySettings $Copy_Settings
							Write-Host "Folder '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}
						ElseIf ($Site.Dst_Folder) # Folder needs to be copied to another folder
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)/$($Site.Dst_Folder)"
							Write-Host "Copy folder '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -SourceFolder $($Site.Src_Folder) -DestinationFolder $($Site.Dst_Folder) -CopySettings $Copy_Settings
							Write-Host "Folder '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}
						Else # Folder needs to be copied to a library
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)"
							Write-Host "Copy folder '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -SourceFolder $($Site.Src_Folder) -CopySettings $Copy_Settings
							Write-Host "Folder '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}

						$Site.Migrated = "Yes" # Adjust the state in the CSV file so we know what was migrated succesfully
					}
					Catch
					{
						Write-Host "'$Src_Path' or '$Dst_Path' not found." -ForegroundColor Red
						$Site.Migrated = "No" # Adjust the state in the CSV file so we know what was migrated succesfully
					}
				}
				ElseIf ($Site.Src_Lib) # If there is a library in the CSV file, only grab this one
				{
					Try
					{
						$Src_Path = "$($Site.Src_Url)/$($Site.Src_Lib)"

						If ($Site.Dst_Subfolder) # Library needs to be copied to a subfolder
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)/$($Site.Dst_Folder)/$($Site.Dst_Subfolder)"
							Write-Host "Copy library '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -DestinationFolder "$($Site.Dst_Folder)/$($Site.Dst_Subfolder)" -CopySettings $Copy_Settings
							Write-Host "Library '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}
						ElseIf ($Site.Dst_Folder) # Library needs to be copied to a folder
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)/$($Site.Dst_Folder)"
							Write-Host "Copy library '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -DestinationFolder $($Site.Dst_Folder) -CopySettings $Copy_Settings
							Write-Host "Library '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}
						Else # Library needs to be copied to another library
						{
							$Dst_Path = "$($Site.Dst_Url)/$($Site.Dst_Lib)"
							Write-Host "Copy library '$Src_Path' to: $Dst_Path" -ForegroundColor Yellow
							Copy-Content -SourceList $Src_Lib -DestinationList $Dst_Lib -CopySettings $Copy_Settings
							Write-Host "Library '$Src_Path' copied to: $Dst_Path" -ForegroundColor Green
						}

						$Site.Migrated = "Yes" # Adjust the state in the CSV file so we know what was migrated succesfully
					}
					Catch
					{
						Write-Host "'$Src_Path' or '$Dst_Path' not found." -ForegroundColor Red
						$Site.Migrated = "No" # Adjust the state in the CSV file so we know what was migrated succesfully
					}
				}
				Else
				{
					Write-Host "Er is niets gevonden in het CSV bestand om te kopieren." -ForegroundColor Red
					$Site.Migrated = "No" # Adjust the state in the CSV file so we know what was migrated succesfully
				}
			}

			# Rebuild CSV file with correct state
			$CSV_Import | Export-Csv $CSV_File -Delimiter ";" -Encoding Default -NoTypeInformation
		}
	}
	Else
	{
		Write-Host "Start this script with PowerShell 5." -ForegroundColor Yellow
	}
}
Else
{
	Write-Host "Not found: $CSV" -ForegroundColor Red
}