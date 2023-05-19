#File with different PsScriptAnalyzer violations

#Using alias
gps

#not using PascalCase
$nowNow = Get-Date
Write-Output $nowNow

#using semicolon
$sdsdd_dsds = Get-Date;

Write-Output `
    "Some text"
`
`

