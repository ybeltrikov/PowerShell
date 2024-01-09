#File with different PsScriptAnalyzer violations

#Using alias
gps

#variable not using camelCase
$NowNow = Get-Date
$nowNow = Get-Date
$now = Get-Date
$NOWNOW = Get-Date
$now_date = Get-Date

Get-Process | Where-Object -FilterScript { $_.ProcessName -eq 'svchost' }

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

$string1 = '_'
$string2 = 'some_text'
$regex = '._.'
$regex2 = '^[a-z]+([A-Za-z0-9]+)+'

$string1 -match $regex
$string2 -match $regex

$string1 -cnotmatch $regex2
$string2 -cnotmatch $regex2
((($string1 -cnotmatch $regex2) -and ($string1 -ne '_')) -or ($string1 -match $regex))
# for _ True -or False

(($string1 -cnotmatch '^[a-z]+([A-Za-z0-9]+)+') -and ($string1 -ne '_')) -or ($string1 -match '._.')

((($string -cnotmatch $regex2) -and ($string2 -ne '_')) -or ($string2 -match $regex))

#show-ast shows AST objects tree - very visual
# comes with ShowPSAst module
Show-Ast -InputObject .\Test-File.ps1 -Verbose

$processes = Get-Process
$firstProcess = $processes[0]
