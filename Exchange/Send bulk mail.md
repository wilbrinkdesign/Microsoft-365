### CSV file

```csv
Email,Coupon
user1@domein.com,NL1234
user2@domein.com,NL5678
```

### Send mail script
```powershell
Start-Transcript -Path "${PSCommandPath}.log" | Out-Null

Import-Csv "$PSScriptRoot\<file>.csv" | ForEach-Object -Process { 
    $Body = "Hello!<br><br>

    Code: <b><font color='green'>$($_.Coupon)</font></b>"
    
    Send-MailMessage -To $_.Email -From "<sender>" -Body $Body -BodyAsHtml -Subject "<subject>" -SmtpServer "<smtp_server>" -Encoding UTF8
}

Stop-Transcript | Out-Null
```