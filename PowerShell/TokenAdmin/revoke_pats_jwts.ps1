$uri = 'https://andresgallo36test1.visualstudio.com/'

(New-TemporaryFile | %{ Remove-Item $_; New-Item -ItemType Directory $_ }).FullName | Push-Location

Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile 'nuget.exe'
&'.\nuget.exe' 'install' 'Microsoft.VisualStudio.Services.InteractiveClient' '-Source' 'https://www.nuget.org/api/v2'

Add-Type -Path "$((Get-ChildItem 'Microsoft.VisualStudio.Services.Client.*\lib\net45').FullName)\Microsoft.VisualStudio.Services.Common.dll" -ErrorAction SilentlyContinue
#Add-Type -Path "$((Get-ChildItem 'Newtonsoft.Json.*\lib\net45').FullName)\Newtonsoft.Json.dll" -ErrorAction SilentlyContinue
Add-Type -Path "$((Get-ChildItem 'Microsoft.AspNet.WebApi.Client.*\lib\net45').FullName)\System.Net.Http.Formatting.dll" -ErrorAction SilentlyContinue
Add-Type -Path "$((Get-ChildItem 'Microsoft.VisualStudio.Services.Client.*\lib\net45').FullName)\Microsoft.VisualStudio.Services.WebApi.dll" -ErrorAction SilentlyContinue
Add-Type -Path "$((Get-ChildItem 'Microsoft.IdentityModel.Clients.ActiveDirectory.*\lib\net45').FullName)\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" -ErrorAction SilentlyContinue
Add-Type -Path "$((Get-ChildItem 'WindowsAzure.ServiceBus.*\lib\net45-full').FullName)\Microsoft.ServiceBus.dll" -ErrorAction SilentlyContinue
Add-Type -Path "$((Get-ChildItem 'Microsoft.VisualStudio.Services.InteractiveClient.*\lib\net45').FullName)\Microsoft.VisualStudio.Services.Client.Interactive.dll" -ErrorAction SilentlyContinue

New-Object Microsoft.VisualStudio.Services.WebApi.VssConnection(
    [uri]$uri, 
    $(New-Object Microsoft.VisualStudio.Services.Common.VssCredentials(
        $(New-Object Microsoft.VisualStudio.Services.Common.WindowsCredential),
        $(New-Object Microsoft.VisualStudio.Services.Client.VssFederatedCredential),
        [Microsoft.VisualStudio.Services.Common.CredentialPromptType]::PromptIfNeeded
    ))
)
<#
VssConnection c = new VssConnection(new Uri("https://andresgallo36test1.visualstudio.com"), new VssCredentials(new WindowsCredential(), new VssFederatedCredential(), CredentialPromptType.PromptIfNeeded));
            c.ConnectAsync().SyncResult();

            c.Credentials.TryGetTokenProvider(new Uri("https://andresgallo36test1.visualstudio.com/_apis/connectionData?connectOptions=0&lastChangeId=46415907&lastChangeId64=46415907"), out IssuedTokenProvider p);

            var t = (VssFederatedToken)p.CurrentToken;
            var cc = t.CookieCollection;

            foreach (var k in cc)
                Console.WriteLine(k);
    
    #>
#Pop-Location
