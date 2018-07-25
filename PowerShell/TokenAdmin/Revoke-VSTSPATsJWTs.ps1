param(
    [parameter(Mandatory=$true)]
    [string] $VSTSAccountName,

    [parameter(Mandatory=$true)]
    [string] $PAT,

    [parameter(Mandatory=$false)]
    [string] $UPNsFileLocation
)

$ErrorActionPreference = 'Stop'
$date = '2018-07-12T12:30:00.000Z'

if($UPNsFileLocation){
    $upns = Get-Content $UPNsFileLocation
}

$token = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("PAT:$PAT"))
$headers = @{
    'Authorization' = "Basic $token"
}

$pageSize = 990

Write-Host 'Revoking JWTs...'
$uri = "https://$VSTSAccountName.vssps.visualstudio.com/_apis/tokenAdmin/revocationRules?api-version=5.0-preview.1"
$params = New-Object psobject -property @{
    'scopes' = 'vso.packaging vso.packaging_write vso.packaging_manage'
    'createdBefore' = $date
} | ConvertTo-Json
$r = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $params -ContentType 'application/json'
Write-Host 'JWTs revoked'

if($upns){
    Write-Host 'Getting list of users in collection...'
    $baseUri = "https://$VSTSAccountName.vssps.visualstudio.com/_apis/graph/users?subjectTypes=aad,msa&"
    $continuationToken = $null
    $descriptors = do{
        $uri = $baseUri
        if($continuationToken){
            $uri = "$($uri)continuationToken=$continuationToken&"
        }
        $uri = "$($uri)api-version=5.0-preview.1"

        $r = Invoke-WebRequest -Method Get -Uri $uri -Headers $headers -ContentType 'application/json'
        $continuationToken = $r.Headers.'X-MS-ContinuationToken'

        $j = $r.Content | ConvertFrom-Json
        $j.value | ?{ $upns -icontains $_.principalName } | %{
            $_.descriptor
        }
    } while($continuationToken)
    Write-Host "Selected $(($descriptors | Measure-Object).Count) user(s)"

    $before = (Get-Date $date).ToUniversalTime()
    Write-Host 'Getting list of PATs from selected users...'
    $authorizationIds = $descriptors | %{
        $baseUri = "https://$VSTSAccountName.vssps.visualstudio.com/_apis/tokenAdmin/personalAccessTokens/$_/?"
        $continuationToken = $null

        do{
            $uri = $baseUri
            if($continuationToken){
                $uri = "$($uri)continuationToken=$continuationToken&"
            }
            $uri = "$($uri)api-version=5.0-preview.1"

            $r = Invoke-WebRequest -Method Get -Uri $uri -Headers $headers -ContentType 'application/json'

            $j = $r.Content | ConvertFrom-Json
            $continuationToken = $j.continuationToken

            $j.value | ?{ [datetime]::SpecifyKind((Get-Date $_.validFrom), [DateTimeKind]::Utc) -le $before } | %{
                $_.authorizationId
            }
        } while($continuationToken)
    }
    Write-Host "Selected $(($authorizationIds | Measure-Object).Count) PAT(s)"

    Write-Host 'Revoking selected PATs...'
    if($authorizationIds){
        $uri = "https://$VSTSAccountName.vssps.visualstudio.com/_apis/tokenAdmin/revocations?api-version=5.0-preview.1"

        $authorizations = [array]($authorizationIds | %{ New-Object psobject -property @{'authorizationId'=$_} })
        $pages = [math]::Ceiling($authorizations.Length / $pageSize)
        0..($pages-1) | %{
            $params = ConvertTo-Json ([array]($authorizations | Select-Object -Skip ($_ * $pageSize) -First $pageSize))
            $r = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $params -ContentType 'application/json'
        }
    }
    Write-Host 'PATs revoked'
}
