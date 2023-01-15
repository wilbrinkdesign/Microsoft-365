$allUsers = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited | select UserPrincipalName,Alias,DisplayName 
 
Foreach ($user in $allUsers) 
{ 
    $gebruiker_email = $user.UserPrincipalName 
    $gebruiker_id = Get-ADUser -Filter { EmailAddress -like $gebruiker_email } | select SamAccountName 
 
    $path = "<path>\$($gebruiker_id.SamAccountName).<extenstion>"
    $photo = Get-Userphoto -identity $user.UserPrincipalName -ErrorAction SilentlyContinue 
     
    If ($photo.PictureData -ne $null) 
    { 
        [io.file]::WriteAllBytes($path,$photo.PictureData) # Download file 
        $ad_photo = [byte[]](Get-Content "$path" -Encoding byte) 
        Set-ADUser $gebruiker_id.SamAccountName -Replace @{thumbnailPhoto=$ad_photo} # Update photo in AD
    } 
} 