$hchkKey = 'lmSyI-ixjkdBMCtsXtk9rQXVUaPB_YKm'

Import-Module D:\Users\dclark\Documents\Git\PS.HealthCheck\PS.HealthCheck\PS.HealthCheck.psd1

Describe PS.HealthCheck {
    Context "API key parameter not specified" {
        It "Connects to the HealthCheck API" {
            Connect-HealthCheck -ApiKey $hchkKey | Should Not throw
        }
        It "Creates Checks" {
            $newChk = New-HealthCheck -Name 'ci-test1' -Tag 'ci test' -Timeout 86400 -Grace 3600 -Channel ''
            $newChk.name | Should Be 'ci-test1'
            $newChk.tag | Should Be 'ci test'
            $newChk.timeout | Should Be 86400
            $newChk.grace | Should Be 3600
            $newChk.channel | Should Be ''
        }
        It "Lists checks" {
            $hchk = Get-HealthCheck
            $hchk.Count | Should BeGreaterThan 0
            $ciTest = $hchk | Where-Object {$_.Name -eq 'ci-test1'}
            $ciTest.name | Should BeExactly 'ci-test1'
            $ciTest.tag | Should Be 'ci test'
            $ciTest.timeout | Should Be 86400
            $ciTest.grace | Should Be 3600
            $ciTest.channel | Should Be ''
        }
    }
    Context "API key parameter specified" {
        It "Creates Checks" {
            $newChk = New-HealthCheck -Name 'ci-test2' -Tag 'ci test' -Timeout 86400 -Grace 3600 -Channel '' -ApiKey $hchkKey
            $newChk.name | Should Be 'ci-test2'
            $newChk.tag | Should Be 'ci test'
            $newChk.timeout | Should Be 86400
            $newChk.grace | Should Be 3600
            $newChk.channel | Should Be ''
        }
        It "Lists checks" {
            $hchk = Get-HealthCheck -ApiKey $hchkKey
            $hchk.Count | Should BeGreaterThan 0
            $ciTest = $hchk | Where-Object {$_.Name -eq 'ci-test2'}
            $ciTest.name | Should BeExactly 'ci-test2'
            $ciTest.tag | Should Be 'ci test'
            $ciTest.timeout | Should Be 86400
            $ciTest.grace | Should Be 3600
            $ciTest.channel | Should Be ''
        }
    }
}
