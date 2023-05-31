#File with different PsScriptAnalyzer violations

#Using alias
gps

#variable not using camelCase
$NowNow = Get-Date

$nowNow = Get-Date

$now = Get-Date

$NOWNOW = Get-Date

$now_date = Get-Date

Write-Output $nowNow
Write-Output $now_date
Write-Output $now

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

