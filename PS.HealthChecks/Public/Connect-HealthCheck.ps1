function Connect-HealthCheck
{
<#
.SYNOPSIS
    The Connect-HealthCheck cmdlet store the API key for the HealthCheck module cmdlets.

    Connect-HealthCheck will only store the API key, no validation is done.
.DESCRIPTION
    The Connect-B2Cloud cmdlet is used to store the API key for the HealthCheck cmdlets.

    The API key can be obtained from your HealthCheck account page.
.EXAMPLE
    Connect-HealthCheck

    The above cmdlet will prompt for the API key and save the API key for use in the other HealthCheck modules.
.EXAMPLE
    PS C:\>Connect-B2Cloud -ApiKey YOUR_API_KEY

    The above cmdlet will take the given API key and save the API key for use in the other HealthCheck modules.
.INPUTS
    System.String

        This cmdlet takes the API key as a string.
.OUTPUTS
    None
.NOTES
    Connect-HealthCheck will only store the API key, no validation is done.
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
        # The API key to access the HealthCheck account.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key')]
        [String]$ApiKey
    )

    Begin
    {
        # By default PowerShell will not accept TLS 1.2 connections.
        # This can be fixed by running the code below.
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
        catch {
            throw 'Unable to set PowerShell to accept TLS 1.2 connections, unable to continue.'
        }
        [Hashtable]$sessionHeaders = @{'X-Api-Key'=$ApiKey}
        [Uri]$hchkApiUri = 'https://healthchecks.io/api/v1/checks/'
    }
    Process
    {
        try
        {
            Invoke-RestMethod -Method Get -Uri $hchkApiUri -Headers $sessionHeaders | Out-Null
            [String]$script:SavedHealthCheckApi = $ApiKey
        }
        catch
        {
            $errorDetail = $_.Exception.Message
            Write-Error -Exception "Unable to authenticate with given APIKey.`n`r$errorDetail" `
                -Message "Unable to authenticate with given APIKey.`n`r$errorDetail" -Category AuthenticationError
        }
    }
}