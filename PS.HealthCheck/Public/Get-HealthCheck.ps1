function Get-HealthCheck
{
<#
.SYNOPSIS
    The Get-B2Bucket cmdlet will list buckets associated with the account.
.DESCRIPTION
    The Get-B2Bucket cmdlet will list buckets associated with the account.
    
    An API key is required to use this cmdlet.
.EXAMPLE
    Get-B2Bucket
    
    BucketName       BucketID                 BucketType AccountID
    ----------       --------                 ---------- ---------
    awsome-jack-fang 4a48fe8875c6214145260818 allPrivate 30f20426f0b1
    Kitten Videos    5b232e8875c6214145260818 allPublic  30f20426f0b1
    
    The cmdlet above will return all buckets for the account.
.EXAMPLE
    Get-B2Bucket | Where-Object {$_.BucketName -eq 'awsome-jack-fang'}
    
    BucketName       BucketID                 BucketType AccountID
    ----------       --------                 ---------- ---------
    awsome-jack-fang 4a48fe8875c6214145260818 allPrivate 30f20426f0b1
    
    The cmdlet above will return all buckets and search for the one with
    a name of awsome-jack-fang.
.INPUTS
    System.String
    
        This cmdlet takes the AccountID and ApplicationKey as strings.
        
    System.Uri
    
        This cmdlet takes the ApiUri as a Uri.
.OUTPUTS
    PS.B2.Bucket
    
        The cmdlet will output a PS.B2.Bucket object holding the bucket info.
.LINK
    https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
    [CmdletBinding(SupportsShouldProcess=$false,
                   PositionalBinding)]
    [Alias()]
    [OutputType()]
    Param
    (
        # The Api key for your account.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Uri]$ApiKey = $script:SavedHealthCheckApi
    )
    
    Begin
    {
        if($ApiKey -eq $null)
        {
            throw 'The API key needs to be specified.'
        }
        [Hashtable]$sessionHeaders = @{'X-Api-Key'=$ApiKey}
        [Uri]$hchkApiUri = 'https://healthchecks.io/api/v1/checks/'
    }
    Process
    {
        $hchkInfo = Invoke-RestMethod -Method Get -Uri $hchkApiUri -Headers $sessionHeaders
        foreach($info in $hchkInfo.checks)
        {
            $hchkReturnInfo = [PSCustomObject]@{
                'Name' = $info.name
                'Tag' = $info.tags
                'Timeout' = $info.timeout
                'Grace' = $info.grace
                'PingURL' = $info.ping_url
                'PingCount' = $info.n_pings
                'LastPing' = $info.last_ping
                'NextPing' = $info.next_ping
            }
            Write-Output $hchkReturnInfo
        }
    }
}