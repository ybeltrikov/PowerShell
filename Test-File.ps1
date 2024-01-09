#File with different PsScriptAnalyzer violations

#Using alias
gps

#variable not using camelCase
$NowNow = Get-Date
$nowNow = Get-Date
$now = Get-Date
$NOWNOW = Get-Date
$now_date = Get-Date

[System.Collections.ArrayList]$labels = @()

[string]$variable = 'hello'
$variable = 'hello again'

Write-Output $nowNow
Write-Output $now_date
Write-Output $now
Write-Output $labels

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

Write-Output "Output 1"
$date = Get-Date
Write-Output $date
Write-Output $variable
Get-Date `
    -Verbose




#show-ast shows AST objects tree - very visual
# comes with ShowPSAst module
Show-Ast -InputObject .\Test-File.ps1