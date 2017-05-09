#Requires -Modules psake

using namespace System.Diagnostics.CodeAnalysis;

Properties {
    $ModuleName = 'PS.HealthChecks'

    [SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments','')]
    $SrcDir = '{0}\{1}' -f $PSScriptRoot, $ModuleName

    [SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments','')]
    $ReleaseDir = '{0}\Release' -f $PSScriptRoot

    [SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments','')]
    $TestDir = '{0}\Tests' -f $PSScriptRoot

    [SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments','')]
    $TestOutputFile = '{0}\TestResults.xml' -f $PSScriptRoot

    [SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments','')]
    $ModuleDir = '{0}\{1}' -f $ReleaseDir, $ModuleName

    [SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments','')]
    $DotnetDir = '{0}\{1}' -f $PSScriptRoot, 'dotnet'

    $ManifestParam = @{
        Path = "$ModuleDir\PS.HealthChecks.psd1"
        ModuleVersion = "$env:APPVEYOR_BUILD_VERSION"
        RootModule = 'PS.HealthChecks.psm1'
        Guid = '3145d0f8-7117-4c5a-904c-3d496fe04ae0'
        Author = 'Dakota Clark'
        CompanyName = ''
        Copyright = "(c) $([datetime]::Now.Year) Dakota Clark. All rights reserved."
        Description = 'A PowerShell module used to interact with the HealthCheck API.'
        PowerShellVersion = '5.0'
        CmdletsToExport = @('Connect-HealthCheck','Get-HealthCheck','New-HealthCheck')
        Tags = @('HealthCheck','Health','Check','Cron','monitoring','monitor','crontab','scheduled','task')
        LicenseUri = 'https://github.com/Persistent13/PS.HealthChecks/blob/master/LICENSE.md'
        ProjectUri = 'https://github.com/Persistent13/PS.HealthChecks'
    }
}

Task default -depends Test

Task Build -depends Clean, Init -requiredVariables $SrcDir, $ReleaseDir, $DotnetDir {
    Copy-Item -Recurse -Force -Path $SrcDir -Destination $ReleaseDir | Out-Null
    Invoke-WebRequest -UseBasicParsing -Uri 'https://go.microsoft.com/fwlink/?linkid=843426' -OutFile $DotnetDir\dotnet.zip
    Expand-Archive -Path $DotnetDir\dotnet.zip -DestinationPath $DotnetDir -Force
    $env:DOTNET_INSTALL_DIR = "$PSScriptRoot\dotnet"
    $env:Path = "$env:Path;$env:DOTNET_INSTALL_DIR"
    exec { dotnet build $PSScriptRoot\HealthChecks.Class\HealthChecks.csproj -c Build -o $DotnetDir\Build }
    $artifacts = Get-ChildItem -Path $DotnetDir\Build -Recurse -Filter '*.dll'
    Copy-Item -Force -LiteralPath $artifacts.FullName -Destination $ReleaseDir\lib
}

Task Test -depends Build -requiredVariables $TestDir {
    if ($env:APPVEYOR) {
        Import-Module Pester
        $test = Invoke-Pester -Path $TestDir -OutputFormat NUnitXml -OutputFile $TestOutputFile -PassThru
        if($test.FailedCount -gt 0){ throw "There were $($test.FailedCount) failed tests during the build." }

        [Uri]$uri = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID
        Invoke-WebRequest -Uri $uri -Method Post -InFile $TestOutputFile | Out-Null
        #(New-Object 'System.Net.WebClient').UploadFile($uri, $TestOutputFile)
    } else {
        $test = Invoke-Pester -Path $TestDir -PassThru
        if($test.FailedCount -gt 0){ throw "There were $($test.FailedCount) failed tests during the build." }
    }
}

Task Release -depends Build, Test -precondition { $env:APPVEYOR -ne $null } {
    Update-ModuleManifest @ManifestParam
    Import-Module PowershellGet
    Publish-Module -NuGetApiKey $env:APPVEYOR_PS_GALLERY_API_KEY -Path $ModuleDir
}

Task Init -requiredVariables $ReleaseDir {
    if (-not (Test-Path $ReleaseDir)) {
        New-Item -ItemType Directory -Path $ReleaseDir | Out-Null
    }
}

Task Clean -requiredVariables $ReleaseDir {
    if (Test-Path $ReleaseDir) {
        Remove-Item -Recurse -Force -Path $ReleaseDir | Out-Null
    }
}
