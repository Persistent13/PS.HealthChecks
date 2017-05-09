using module ..\Class\Check.Class.psm1
function New-HealthCheck
{
<#
.SYNOPSIS
    New-HealthCheck will create a new health check.
.DESCRIPTION
    New-HealthCheck will create a new health check.

    An API key is required to use this cmdlet.
.EXAMPLE
    New-HealthCheck -Name stoic-barbarian-lemur -Tag "prod db-dump"

    Grace       : 3600
    LastPing    :
    PingCount   : 0
    Name        : stoic-barbarian-lemur
    NextPing    :
    PingURL     : https://hchk.io/25c55e7c-8092-4d21-ad06-7dacfbb6fc10
    Tags        : prod db-dump
    Timeout     : 86400

    The cmdlet above will create a new check with the name of stoic-barbarian-lemur and tags of "prod db-dump".

    All other options are set to default and are not required to be specified.
.EXAMPLE
    PS C:\>New-HealthCheck

    Grace       : 3600
    LastPing    :
    PingCount   : 0
    Name        :
    NextPing    :
    PingURL     : https://hchk.io/25c55e7c-8092-4d21-ad06-7dacfbb6fc10
    Tags        :
    Timeout     : 86400

    The cmdlet above will create a new check with all default properties.
.EXAMPLE
    PS C:\>New-HealthCheck -Grace 60 -Timeout 60

    Grace       : 60
    LastPing    :
    PingCount   : 0
    Name        :
    NextPing    :
    PingURL     : https://hchk.io/25c55e7c-8092-4d21-ad06-7dacfbb6fc10
    Tags        :
    Timeout     : 60

    The cmdlet above will create a new check with grace and timeout set to the smallest value of 60 seconds.
.EXAMPLE
    PS C:\>New-HealthCheck -Grace 604800 -Timeout 604800

    Grace       : 604800
    LastPing    :
    PingCount   : 0
    Name        :
    NextPing    :
    PingURL     : https://hchk.io/25c55e7c-8092-4d21-ad06-7dacfbb6fc10
    Tags        :
    Timeout     : 604800

    The cmdlet above will create a new check with grace and timeout set to the largest value of 604800 seconds (1 week).
.EXAMPLE
    PS C:\>New-HealthCheck -Channel "*"

    Grace       : 3600
    LastPing    :
    PingCount   : 0
    Name        :
    NextPing    :
    PingURL     : https://hchk.io/25c55e7c-8092-4d21-ad06-7dacfbb6fc10
    Tags        :
    Timeout     : 86400

    The cmdlet above will create a new check set to alarm on all integration channels.

    See more https://healthchecks.io/integrations/
.INPUTS
    System.String

        This cmdlet takes the check name, tags, channel, and API key as strings.

    System.UInt32

        This cmdlets takes the grace and timout periods as unsigned, 32 bit integers.
.OUTPUTS
    HealthChecks.Check

        This cmdlet returns a check object for new check created.
.LINK
    https://healthchecks.io/docs/
.ROLE
    PS.HealthChecks
.FUNCTIONALITY
    PS.HealthChecks
#>
    [CmdletBinding(SupportsShouldProcess,
                   PositionalBinding,
                   ConfirmImpact='Low')]
    [Alias()]
    [OutputType([HealthChecks.Check])]
    Param
    (
        # The name of the new check, maximum of 99 characters.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateLength(0,99)]
        [String[]]$Name = '',
        # Tag(s) for the check, maximum of 499 characters.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateLength(0,499)]
        [String]$Tag = '',
        # Timeout period for the check, maximum 604800 seconds (1 week).
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(60,604800)]
        [UInt32]$Timeout = 86400,
        # Grace period for the check, maximum 604800 seconds (1 week).
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(60,604800)]
        [UInt32]$Grace = 3600,
        # Alert channel to send notifications on, maximum of 49 characters.
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
        [String]$ApiKey = $script:SavedHealthCheckApi
    )

    Begin
    {
        $ErrorActionPreference = 'Stop'
        if($ApiKey -eq $null)
        {
            try
            {
                $credParams = @{
                    Message = 'Enter you API key below.'
                    UserName = 'Enter you API key below.'
                }
                $ApiKey = (Get-Credential @credParams).GetNetworkCredential().Password
            }
            catch
            {
                $PSCmdlet.ThrowTerminatingError($error)
            }
        }
        try
        {
            # By default PowerShell will not accept TLS 1.2 connections.
            # This can be fixed by running the code below.
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
        catch
        {
            Write-Verbose -Message 'Unable to enable TLS 1.2 for PowerShell HTTP connections.'
            $PSCmdlet.ThrowTerminatingError($PSItem)
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
                    $hchkReturnInfo = [HealthChecks.Check]::New($hchkInfo.name,
                                                                $hchkInfo.tags,
                                                                $hchkInfo.timeout,
                                                                $hchkInfo.grace,
                                                                $hchkInfo.ping_url,
                                                                $hchkInfo.n_pings,
                                                                $hchkInfo.last_ping,
                                                                $hchkInfo.next_ping)
                    Write-Output $hchkReturnInfo
                }
                catch
                {
                    $PSCmdlet.ThrowTerminatingError($PSItem)
                }
            }
        }
    }
}