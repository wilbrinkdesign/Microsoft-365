%LOCALAPPDATA%\Microsoft\OneDrive\onedrive.exe /reset
%LOCALAPPDATA%\Microsoft\OneDrive\onedrive.exe
netsh winsock reset catalog
/c for /F "tokens=1,2,3 delims==" %G in ('cmdkey /list ^| findstr "teams OneDrive Office outlook"') do cmdkey /delete:%H
reg delete HKEY_CURRENT_USER\Software\Microsoft\OneDrive\Accounts\Business1