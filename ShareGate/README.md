If you are looking for a way to migrate your SharePoint Online files with ShareGate, look no further! These scripts will ensure a safe migration. Create the library/folder structure you need and do the actual migration. The migration script leans on the ShareGate software that includes the PowerShell module. The cleanup and structure scripts lean on the Microsoft SharePoint Online PowerShell module.

### The scripts
1. ShareGate structure.ps1
2. ShareGate migrate.ps1
3. ShareGate cleanup.ps1

Script 1 will create the structure for the destination site. This script will only create libraries and folders/subfolders. It will not create the destination site!

Script 2 will perform the actual migration from one SharePoint site to another. It will monitor which were successful and adjust the migration state accordingly.

Script 3 will remove all libraries and folders/subfolders from the source site. Be careful!

### CSV structure

```csv
Migrated;Src_Url;Src_Lib;Src_Folder;Src_Subfolder;Dst_Url;Dst_Lib;Dst_Folder;Dst_Subfolder
Yes;https://tenantname.sharepoint.com/sites/SiteA;Library A;Folder A;Subfolder A;https://tenantname.sharepoint.com/sites/SiteB;Library B;Folder B;
;https://tenantname.sharepoint.com/sites/SiteA;Library A;Folder A;;https://tenantname.sharepoint.com/sites/SiteB;Library B;Folder B;Subfolder B
```

### Tips
- Use the parameter '-CSV' to pass your own CSV file to the script.
- Use the parameter '-DisableVersionHistory' if you do not want to copy any versions of the SharePoint files.
- Start the ShareGate tool on your server and click on "Tasks". You will see all the PowerShell tasks started from the command line.