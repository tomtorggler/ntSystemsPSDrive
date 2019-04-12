A SHiPS provider for the blog.

Try it: 

```powershell
New-PSDrive -Name ntSystems -PSProvider ships -Root ntSystemsPSDrive#Home
Get-ChildItem ntSystems:

dir 'ntSystems:\Posts by Author\thomas torggler\' | Select-Object name,url 
```