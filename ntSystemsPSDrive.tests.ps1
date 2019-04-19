$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$here\ntSystemsPSDrive\ntSystemsPSDrive.psd1"

Describe "Test PSDrive creation" {
    Context "New-ntSystemsPSDrive" {
        $result1 = New-ntSystemsPSDrive -Name ntsystems 
        $result2 = New-ntSystemsPSDrive -Name ntsystems -WarningVariable warn -WarningAction SilentlyContinue
        It "Should return an object of type [Microsoft.PowerShell.SHiPS.SHiPSDrive]" {
            $result1 | Should -BeOfType [Microsoft.PowerShell.SHiPS.SHiPSDrive]
        }
        It "Should create a PSDrive in the Global scope with Provider SHiPS" {
            Get-PSDrive -PSProvider SHiPS | Should -BeOfType [Microsoft.PowerShell.SHiPS.SHiPSDrive]
        }
        It "Should warn if drive cannot be created" {
            $warn | Should -Match "Unable to create PSDrive"
        }
        It "Should not return an object if drive cannot be created" {
            $result2 | Should -Be $Null
        }
    }
}

Describe "Test navigation" {
    Context "Get-ChildItem" {
        $result = Get-ChildItem -Path ntsystems: -Recurse
        It "Should return more than 60 folder objects" {
            $result.Where{$_.items}.count | Should -BeGreaterThan 60
        }
        It "Should return more than 1000 post objects" {
            $result.Where{$_.url}.count | Should -BeGreaterThan 1000
        }
    }
    Context "Leaf Objects" {
        $result = Get-ChildItem -Path ntsystems: -Recurse
        $member = $result.Where{$_.url}[0] | Get-Member -Name GetContent 
        $content = Get-Content $result.Where{$_.url}[0].PSPath
        It "Should have a GetContent method" {
            $member.Name | Should -Be GetContent
        }
        It "Should return content as string when GetContent() is called" {
            $content | Should -BeOfType [string]
            $content | Should -Not -BeNullOrEmpty
        }
    }
    Context "Set-Location" {
        Push-Location
        $result = Set-Location ntsystems: -PassThru
        Pop-Location
        It "Should change location to SHiPS drive" {
            $result | Should -BeOfType [System.Management.Automation.PathInfo]
        }
    }
}

Remove-Module ntSystemsPSDrive,SHiPS
