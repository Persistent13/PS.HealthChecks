# Remove the module and then import the module
$WorkspaceRoot = $(Get-Item $PSScriptRoot).Parent.FullName
Remove-Module 'PS.HealthChecks' -ErrorAction Ignore
Import-Module "$WorkspaceRoot\PS.HealthChecks\PS.HealthChecks.psd1" -Force

if($env:APPVEYOR_HCHK_API_KEY -eq $null) {
    # Using json key.
    $settings = Get-Content $PSScriptRoot\testSettings.json | ConvertFrom-Json
    $env:APPVEYOR_HCHK_API_KEY = $settings.ApiKey
}

Describe "PS.HealthChecks Module tests" {
    Context "Test module import" {
        It "Should export all commands" {
            $module = Get-Module -Name PS.HealthChecks
            # The count should always equal the number of cmdlets
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
                $ciTest = $hchk | Where-Object {$_.Name -eq 'ci-test1'}
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
                $ciTest = $hchk | Where-Object {$_.Name -eq 'ci-test2'}
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