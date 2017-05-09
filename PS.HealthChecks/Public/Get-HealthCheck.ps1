function Get-HealthCheck
{
<#
.SYNOPSIS
    The Get-HealthCheck cmdlet will list all checks associated with the account.
.DESCRIPTION
    The Get-HealthCheck cmdlet will list all checks associated with the account.

    An API key is required to use this cmdlet.
.EXAMPLE
    Get-HealthCheck

    Grace       : 900
    LastPing    : Saturday, July 9, 2016 6:58:43 AM
    PingCount   : 1
    Name        : Api test 1
    NextPing    : Saturday, July 9, 2016 7:58:43 AM
    PingURL     : https://hchk.io/25c55e7c-8092-4d21-ad06-7dacfbb6fc10
    Tags        : foo
    Timeout     : 3600

    Grace       : 60
    LastPing    :
    PingCount   : 0
    Name        : Api test 2
    NextPing    :
    PingURL     : https://hchk.io/7e1b6e61-b16f-4671-bae3-e3233edd1b5e
    Tags        : bar baz
    Timeout     : 60

    The cmdlet above will return all checks for the account.
.EXAMPLE
    PS C:\>Get-B2Bucket | Where-Object {$_.Name -eq 'Api test 2'}

    Grace       : 60
    LastPing    :
    PingCount   : 0
    Name        : Api test 2
    NextPing    :
    PingURL     : https://hchk.io/7e1b6e61-b16f-4671-bae3-e3233edd1b5e
    Tags        : bar baz
    Timeout     : 60

    The cmdlet above will return all buckets and search for the one with a name of "Api test 2".
.INPUTS
    System.Uri

        This cmdlet takes the AccountID and ApplicationKey as strings.
.OUTPUTS
    Check

        This cmdlet returns a check object for each check found.
.LINK
    https://healthchecks.io/docs/
.ROLE
    PS.HealthChecks
.FUNCTIONALITY
    PS.HealthChecks
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
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::New(
                        ([System.ArgumentException]'You must set the ApiKey parameter. Did you run Connect-HealthCheck?'),
                        $null,
                        [System.Management.Automation.ErrorCategory]::AuthenticationError,
                        $PSItem
                    )
                )
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
        try
        {
            $hchkInfo = Invoke-RestMethod -Method Get -Uri $hchkApiUri -Headers $sessionHeaders
            foreach($info in $hchkInfo.checks)
            {
                $hchkReturnInfo = [Healthchecks.Check]::New($info.name,
                                                            $info.tags,
                                                            $info.timeout,
                                                            $info.grace,
                                                            $info.ping_url,
                                                            $info.n_pings,
                                                            $info.last_ping,
                                                            $info.next_ping)
                Write-Output $hchkReturnInfo
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}