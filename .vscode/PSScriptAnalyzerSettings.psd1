@{
    CustomRulePath = '.\.vscode\CustomPSScriptAnalyzerRules.psm1'
    #CustomRulePath = '.\.vscode\CustomPSScriptAnalyzerRules-Pascal.psm1'
    #CustomRulePath = '.\.vscode\CustomPSScriptAnalyzerRules-Backtick.psm1'
    IncludeDefaultRules = $true
    Rules = @{
        PSAvoidLongLines  = @{
            Enable     = $true
            MaximumLineLength = 115
        }
        PSAvoidSemicolonsAsLineTerminators  = @{
            Enable     = $true
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            NoEmptyLineBefore = $false
            IgnoreOneLineBlock = $true
            NewLineAfter = $true
        }
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }
        PSUseConsistentWhitespace  = @{
            Enable                          = $true
            CheckInnerBrace                 = $true
            CheckOpenBrace                  = $true
            CheckOpenParen                  = $true
            CheckOperator                   = $true
            CheckPipe                       = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator                  = $true
            CheckParameter                  = $false
            IgnoreAssignmentOperatorInsideHashTable = $false
        }
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind = 'space'
        }
    }
    ExcludeRules = @(
    )
}