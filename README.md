A SHiPS provider for [ntSystems.it](https://ntsystem.it/).

This module uses the [SHiPS](https://github.com/PowerShell/SHiPS/) module to create a PowerShell provider for our blog. 

Try it: 

```powershell
Import-Module ntSystemsPSDrive
New-ntSystemsPSDrive
dir ntSystems:
dir ntSystems: -Depth 1
Get-ChildItem 'ntSystems:\Posts by Category\PowerShell\' | Select-Object -Property name,url
Get-Content 'ntSystems:\Posts by Category\ntSystems\Jekyll Fun: Consuming ntSystems with PowerShell' 
```
