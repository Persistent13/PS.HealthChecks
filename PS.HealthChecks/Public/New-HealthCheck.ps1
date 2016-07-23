function New-HealthCheck
{
<#
.SYNOPSIS
    New-B2Bucket will create a new private or public bucket and requires a globally unique name.
.DESCRIPTION
    New-B2Bucket will create a new private or public bucket and requires a globally unique name.

    An API key is required to use this cmdlet.
.EXAMPLE
    New-B2Bucket -BucketName stoic-barbarian-lemur -BucketType allPublic

    BucketName            BucketID                 BucketType AccountID
    ----------            --------                 ---------- ---------
    stoic-barbarian-lemur 4a48fe8875c6214145260818 allPublic  010203040506

    The cmdlet above will create a public bucket with the name of stoic-barbarian-lemur.
.EXAMPLE
    PS C:\>New-B2Bucket -BucketName stoic-barbarian-lemur, frisky-navigator-lion -BucketType allPrivate

    BucketName            BucketID                 BucketType AccountID
    ----------            --------                 ---------- ---------
    stoic-barbarian-lemur 4a48fe8875c6214145260818 allPrivate 010203040506
    frisky-navigator-lion 4a48fe8875c6214145260819 allPrivate 010203040506

    The cmdlet above will create a public bucket with the name of stoic-barbarian-lemur and frisky-navigator-lion.
.INPUTS
    System.String

        This cmdlet takes the AccountID and ApplicationKey as strings.
.OUTPUTS
    PS.B2.Bucket

        The cmdlet will output a PS.B2.Bucket object holding the bucket info.

    System.Uri

        This cmdlet takes the ApiUri as a uri.
.LINK
    https://www.backblaze.com/b2/docs/
.ROLE
    PS.B2
.FUNCTIONALITY
    PS.B2
#>
    [CmdletBinding(SupportsShouldProcess,
                   PositionalBinding,
                   ConfirmImpact='Low')]
    [Alias()]
    [OutputType()]
    Param
    (
        # The name of the new check.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateLength(0,99)]
        [String[]]$Name = '',
        # Tag(s) for the check.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateLength(0,499)]
        [String]$Tag = '',
        # Timeout period for the check, maximum 604800 seconds (1 week).
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt32]$Timeout = 86400,
        # Grace period for the check, maximum 604800 seconds (1 week).
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [UInt32]$Grace = 3600,
        # Alert channel to send notifications on.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateLength(0,49)]
        [String]$Channel = '',
        # Used to bypass confirmation prompts.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Switch]$Force,
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
        foreach($check in $Name)
        {
            if($Force -or $PSCmdlet.ShouldProcess($check, "Create new check."))
            {
                try
                {
                    [String]$sessionBody = @{'name'=$check;'tags'=$Tag;'timeout'=$Timeout;'grace'=$Grace;'channels'=$Channel} | ConvertTo-Json
                    $hchkInfo = Invoke-RestMethod -Method Post -Uri $hchkApiUri -Headers $sessionHeaders -Body $sessionBody
                    $hchkReturnInfo = [PSCustomObject]@{
                        'Name' = $hchkInfo.name
                        'Tag' = $hchkInfo.tags
                        'Timeout' = $hchkInfo.timeout
                        'Grace' = $hchkInfo.grace
                        'PingURL' = $hchkInfo.ping_url
                        'PingCount' = $hchkInfo.n_pings
                        'LastPing' = $hchkInfo.last_ping
                        'NextPing' = $hchkInfo.next_ping
                    }
                    Write-Output $hchkReturnInfo
                }
                catch
                {
                    Write-Error "Unable to create the check named "$check"."
                }
            }
        }
    }
}