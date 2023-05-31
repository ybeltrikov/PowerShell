#File with different PsScriptAnalyzer violations

#Using alias
gps

#variable not using PascalCase
$nowNow = Get-Date
Write-Output $nowNow

#parameter name not using PascalCase
Get-Date -verbose

#parameter name using PascalCase
Get-Date -Verbose


#using semicolon
$sdsdd_dsds = Get-Date;

Write-Output `
    "Some text"
`
`

