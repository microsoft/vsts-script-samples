The `Revoke-VSTSPATsJWTs.ps1` script will revoke all the PATs created before `2018-07-12T12:30:00.000Z` for the selected UPNs that have access to the specified VSTS account and will also expire all the JWTs created before `2018-07-12T12:30:00.000Z` that have any of the `vso.packaging`, `vso.packaging_write` or `vso.packaging_manage` scopes, or a global scope, for the specified VSTS account. 

To specify the list of UPNs, enter the UPN of each user from whom you want to revoke all PATs in a text file in your local file system, one per line. 

The script uses the VSTS Graph and TokenAdmin REST APIs to list PATs, to revoke JWTs and to disable PATs. To authenticate against these APIs, the script needs a valid PAT with all the scopes for, at least, the VSTS account provided to the script. To [create a new PAT in VSTS](https://docs.microsoft.com/en-us/vsts/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts#create-personal-access-tokens-to-authenticate-access) with these properties, you can follow these steps: 
1. Sign in to your VSTS account (`https://{your_vsts_account}.visualstudio.com`). 
2. From the top right corner of your home page, select your `Profile Picture` and go to `Security`. 
3. On the left pane select `Personal access tokens` and in the center pane select `Add`. 
4. Enter a `Description` for your new PAT, select the shortest expiration period for the `Expires In` field and select `{your_vsts_account}` in the `Accounts` field. 
5. For `Authorized Scopes` choose `All scopes` and select `Create`. 
6. Copy the PAT text displayed in the list of tokens. 

Then you can use the PowerShell script with the following parameters: 
```PowerShell
.\Revoke-VSTSPATsJWTs.ps1 -VSTSAccountName '{your_vsts_account}' -PAT '{your_new_pat}' [-UPNsFileLocation '{location_of_your_UPNs_file}']
```

For example: 
```PowerShell
.\Revoke-VSTSPATsJWTs.ps1 -VSTSAccountName 'fabrikam' -PAT '{PAT_text}' -UPNsFileLocation '.\SampleUPNs.txt'
```

If the UPN you used to create the PAT is in the UPNs file and the PAT was created before `2018-07-12T12:30:00.000Z`, your PAT will also be removed. 

If the text file with the UPNs is not provided to the script or if the file is empty, the script will only expire the VSTS account JWTs. 
