function Connect-HealthCheck
{
<#
.SYNOPSIS
    The Connect-B2Cloud cmdlet sets the API key for the Backblaze B2 module cmdlets.
.DESCRIPTION
    The Connect-B2Cloud cmdlet is used to retireve the API Uri, download Uri, and API
    token that authorizes actions againt a B2 account. The cmdlet returns the results
    of the REST query as text if successful and an error if not successful.
    
    The application key and account ID can be obtained from your Backblaze B2 account page.
.EXAMPLE
    Connect-B2Cloud
   
    AccountID       ApiUri                       DownloadUri                Token
    ---------       ------                       -----------                -----
    30f20426f0b1    https://api900.backblaze.com https://f900.backblaze.com YOUR_TOKEN

    The above cmdlet will prompt for the account ID and application key, authenticate, and
    save the token, API Uri, and download Uri returned for use in the other PS.B2 modules.
    
    The API Uri, download Uri, and authorization token will be returned if the cmdlet was successful.
.EXAMPLE
    PS C:\>Connect-B2Cloud -AccountID 30f20426f0b1 -ApplicationKey YOUR_APPLICATION_KEY
   
    AccountID       ApiUri                       DownloadUri                Token
    ---------       ------                       -----------                -----
    30f20426f0b1    https://api900.backblaze.com https://f900.backblaze.com YOUR_TOKEN

    The above cmdlet will take the given account ID and application key authenticate and
    save the token, API Uri, and download Uri returned for use in the other PS.B2 modules.
    
    The API Uri, download Uri, and authorization token will be returned if the cmdlet was successful.
.INPUTS
    System.String

        This cmdlet takes the AccountID and ApplicationKey as strings.
.OUTPUTS
    PS.B2.Account

        The cmdlet will output a PS.B2.Account object holding account authorization info.
.NOTES
    Connect-B2Cloud will always output the account information on a successful connection, to
    prevent this it is recommened to pipe the out put to Out-Null. i.e. Connect-B2Cloud | Out-Null
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
        # The API key to access the HealthCheck account.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Key')]
        [String]$ApiKey
    )
    
    Begin
    {
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