The `Revoke-VSTSPATsJWTs.ps1` script will revoke all the PATs for the selected UPNs that have access to a VSTS account and will also expire all the JWTs for the VSTS account created before `2018-07-12T12:30:00.000Z` that have any of the `app_token vso.packaging vso.packaging_write vso.packaging_manage` scopes. 

Enter the UPN of each user from whom you want to revoke all PATs in a text file in your local file system, one per line. 

[Create a new PAT in VSTS](https://docs.microsoft.com/en-us/vsts/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts#create-personal-access-tokens-to-authenticate-access) by following these steps: 
1. Sign in to your VSTS account (`https://{your_vsts_account}.visualstudio.com`). 
2. From the top right of your home page, select your `Profile Picture` and go to `Security`. 
3. On the left pane select `Personal access tokens` and in the center pane select `Add`. 
4. Enter a `Description` for your new PAT, select the shortest expiration period for the `Expires In` field, and select `{your_vsts_account}` in the `Accounts` field. 
5. For `Authorized Scopes` choose `All scopes` and select `Create`. 
6. Copy the PAT text displayed in the list of tokens. 

Then you can use the PowerShell script with the following parameters: 
```PowerShell
.\Revoke-VSTSPATsJWTs.ps1 -VSTSAccountName '{your_vsts_account}' -PAT '{your_new_pat}' -UPNsFileLocation '{location_of_your_UPNs_file}'
```

For example: 
```PowerShell
.\Revoke-VSTSPATsJWTs.ps1 -VSTSAccountName 'fabrikam' -PAT '{PAT_text}' -UPNsFileLocation '.\UPNs.txt'
```

If the UPN you used to create the PAT is in the UPNs file, your newly created PAT will also be removed. 
