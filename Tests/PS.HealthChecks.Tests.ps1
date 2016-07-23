$WorkspaceRoot = $(Get-Item $PSScriptRoot).Parent.FullName
Remove-Module 'PS.HealthChecks' -ErrorAction Ignore
Import-Module "$WorkspaceRoot\PS.HealthChecks\PS.HealthChecks.psd1" -Force

switch ($env:APPVEYOR_PROJECT_ID) {
    $null {
        $settings = Get-Content .\testSettings.json | ConvertFrom-Json
        $key = $settings.ApiKey
    }
    Default {
        $key = $Env:secure_api
    }
}

InModuleScope PS.HealthChecks {
    Describe PS.HealthChecks {
        Context "API key parameter not specified" {
            It "Connects to the HealthCheck API" {
                {Connect-HealthCheck -ApiKey $key} | Should Not Throw
            }
            It "Creates Checks" {
                {New-HealthCheck -Name 'ci-test1' -Tag 'ci test' -Timeout 86400 -Grace 3600 -Channel ''} | Should Not Throw
            }
            It "Lists checks" {
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
        }
        Context "API key parameter specified" {
            It "Creates Checks" {
                {New-HealthCheck -Name 'ci-test2' -Tag 'ci test' -Timeout 86400 -Grace 3600 -Channel '' -ApiKey $key} | Should Not Throw
            }
            It "Lists checks" {
                $hchk = Get-HealthCheck -ApiKey $key
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