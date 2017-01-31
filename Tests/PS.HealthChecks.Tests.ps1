$ModuleDir = Resolve-Path -Path $PSScriptRoot\..\Release
# Remove the module
Remove-Module 'PS.HealthChecks' -ErrorAction Ignore

if($env:APPVEYOR_HCHK_API_KEY -eq $null) {
    # Using json key.
    $settings = Get-Content $PSScriptRoot\testSettings.json | ConvertFrom-Json
    $env:APPVEYOR_HCHK_API_KEY = $settings.ApiKey
    if($env:APPVEYOR_HCHK_API_KEY -eq $null){ throw 'Unable to set HCHK API key, is the json file present?' }
}

Describe "Project Validation" {

    $files = Get-ChildItem $ModuleDir -Include *.ps1,*.psm1,*.psd1 -Recurse
    $testCases = $files | ForEach-Object { @{file=$_} }

    Context "The project is using valid PowerShell" {
        It "Script <file> should be valid PowerShell" -TestCases $testCases {
            param($file)

            $file.FullName | Should Exist

            $contents = Get-Content -Path $file.fullname -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }

        It "The module can import without errors" {
            {Import-Module "$ModuleDir\PS.HealthChecks\PS.HealthChecks.psd1" -Force} | Should Not Throw
        }
    }
}

# Import the module for the following tests
Import-Module "$ModuleDir\PS.HealthChecks\PS.HealthChecks.psd1" -Force

Describe "PS.HealthChecks Module tests" {
    Context "Test module import" {
        It "Should export all commands" {
            $module = Get-Module -Name PS.HealthChecks
            # The count should always equal the number of public cmdlets
            $module.ExportedCommands.Count | Should Be 3
        }
    }
}
InModuleScope PS.HealthChecks {
    Describe "PS.HealthChecks class tests" {
        Context "Custom classes should instantiate" {
            It "Should create Check object" {
                {[Check]::New('','',60,60,'https://hchk.io/25c55e7c-8092-4d21-ad06-7dacfbb6fc10',0,$null,$null)} | Should Not Throw
            }
        }
    }
    Describe "PS.HealthChecks cmdlet tests" {
        Context "Get cmdlet returns an empty json array" {
            It "Should not throw" {
                # The cmdlet will error out if [dateime] is applied to null ping date values
                {Get-HealthCheck -ApiKey $env:APPVEYOR_HCHK_API_KEY} | Should Not Throw
            }
        }
        Context "Test Connect cmdlet" {
            It "Should not throw" {
                # As long as there is no error we should be good
                {Connect-HealthCheck -ApiKey $env:APPVEYOR_HCHK_API_KEY} | Should Not Throw
            }
        }
        Context "Test New cmdlets" {
            It "Creates Checks without API key" {
                # No errors should generate for a new check
                {New-HealthCheck -Name 'ci-test1' -Tag 'ci test' -Timeout 86400 -Grace 3600 -Channel ''} | Should Not Throw
            }
            It "Creates Checks with API key" {
                # No errors should generate for a new check
                {New-HealthCheck -Name 'ci-test2' -Tag 'ci test' -Timeout 86400 -Grace 3600 -Channel '' -ApiKey $env:APPVEYOR_HCHK_API_KEY} | Should Not Throw
            }
        }
        Context "Test Get cmdlets" {
            It "Lists Checks without API key" {
                $hchk = Get-HealthCheck
                $hchk.Count | Should BeGreaterThan 0
                $ciTest = ($hchk | Where-Object {$_.Name -eq 'ci-test1'})[-1]
                $ciTest.Name | Should BeExactly 'ci-test1'
                $ciTest.Tag | Should BeExactly 'ci test'
                $ciTest.Timeout | Should Be 86400
                $ciTest.Grace | Should Be 3600
                $ciTest.PingURL | Should BeLike 'https://hchk.io/*'
                $ciTest.PingCount | Should Be 0
                $ciTest.LastPing | Should BeNullOrEmpty
                $ciTest.NextPing | Should BeNullOrEmpty
            }
            It "Lists Checks with API key" {
                $hchk = Get-HealthCheck -ApiKey $env:APPVEYOR_HCHK_API_KEY
                $hchk.Count | Should BeGreaterThan 0
                $ciTest = ($hchk | Where-Object {$_.Name -eq 'ci-test2'})[-1]
                $ciTest.Name | Should BeExactly 'ci-test2'
                $ciTest.Tag | Should BeExactly 'ci test'
                $ciTest.Timeout | Should Be 86400
                $ciTest.Grace | Should Be 3600
                $ciTest.PingURL | Should BeLike 'https://hchk.io/*'
                $ciTest.PingCount | Should Be 0
                $ciTest.LastPing | Should BeNullOrEmpty
                $ciTest.NextPing | Should BeNullOrEmpty
            }
        }
    }
}