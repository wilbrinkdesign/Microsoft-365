### Connect a MFA token to a Azure user

```csv
upn,serial number,secret key,timeinterval,manufacturer,model 
user@token2.com,1234567890,S112233445566KKBBAASS,30,Token2,OTPCN
```

### Upload CSV in Azure portal

1. [Azure => Security => Multifactor Authentication => OATH tokens](https://portal.azure.com/#blade/Microsoft_AAD_IAM/MultifactorAuthenticationMenuBlade/HardwareTokens/fromProviders/)
2. Upload CSV
3. Activate on page

[Emulator for testing purposes](https://www.token2.com/site/page/totp-toolset)
