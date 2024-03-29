#Requires -Version 3.0
Function Measure-PascalCase {
    <#
    .SYNOPSIS
        The parameter names should be in PascalCase.

    .DESCRIPTION
        Parameter names should be in PascalCase.
        To fix a violation of this rule, please consider using PascalCase for parameter names.

    .EXAMPLE
        Measure-PascalCase -ScriptBlockAst $ScriptBlockAst

    .INPUTS
        [System.Management.Automation.Language.ScriptBlockAst]

    .OUTPUTS
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]

    .NOTES
        https://msdn.microsoft.com/en-us/library/dd878270(v=vs.85).aspx
        https://msdn.microsoft.com/en-us/library/ms229043(v=vs.110).aspx
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )

    Process {

        $results = @()

        try {
            #region Define predicates to find ASTs.

            [ScriptBlock]$Predicate = {
                Param ([System.Management.Automation.Language.Ast]$Ast)

                [bool]$ReturnValue = $False
                If ($Ast -is [System.Management.Automation.Language.CommandParameterAst]) {

                    [System.Management.Automation.Language.CommandParameterAst]$ParameterAst = $Ast
                    If ($ParameterAst.ParameterName -cnotmatch '^([A-Z][a-z]+)+$') {
                        $ReturnValue = $True
                    }
                }
                return $ReturnValue
            }
            #endregion

            #region Finds ASTs that match the predicates.
            [System.Management.Automation.Language.Ast[]]$Violations = $ScriptBlockAst.FindAll($Predicate, $True)

            If ($Violations.Count -ne 0) {

                Foreach ($Violation in $Violations) {

                    $Result = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        RuleName = $PSCmdlet.MyInvocation.InvocationName
                        Message = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)"
                        Extent = $Violation.Extent
                        "Severity" = "Information"
                        "SuggestedCorrections" = $null
                    }
                    $Results += $Result
                }
            }
            return $Results
            #endregion
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

Function Measure-CamelCase {
    <#
        .SYNOPSIS
            The variables names should be in camelCase.

        .DESCRIPTION
            Variables names should be in camelCase.
            To fix a violation of this rule, please consider using camelCase for variable names.

        .EXAMPLE
            Measure-CamelCase -ScriptBlockAst $ScriptBlockAst
        .INPUTS
            [System.Management.Automation.Language.ScriptBlockAst]

        .OUTPUTS
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]

        .NOTES
            https://msdn.microsoft.com/en-us/library/dd878270(v=vs.85).aspx
            https://msdn.microsoft.com/en-us/library/ms229043(v=vs.110).aspx
#>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )

    Begin {
        #the variable names below will not be reported by the PS Script Analyzer rule
        #shorted list from https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.4
        $exceptionList = @(
            '_'
            '$'
            '?'
            '^'
            '_'
            'ConsoleFileName'
            'EnabledExperimentalFeatures'
            'env:*'
            'Error'
            'ErrorActionPreference'
            'Event'
            'EventArgs'
            'EventSubscriber'
            'ExecutionContext'
            'HOME'
            'Host'
            'IsCoreCLR'
            'IsLinux'
            'IsMacOS'
            'IsWindows'
            'LASTEXITCODE'
            'Matches'
            'MyInvocation'
            'NestedPromptLevel'
            'PID'
            'PROFILE'
            'PSBoundParameters'
            'PSCmdlet'
            'PSCommandPath'
            'PSCulture'
            'PSDebugContext'
            'PSEdition'
            'PSHOME'
            'PSItem'
            'PSScriptRoot'
            'PSSenderInfo'
            'PSUICulture'
            'PSVersionTable'
            'PWD'
            'script:*'
            'Sender'
            'ShellId'
            'StackTrace'
            'Using:*'
        )
    }

    Process {

        $Results = @()

        try {
            #region Define predicates to find ASTs.

            [ScriptBlock]$Predicate = {
                Param ([System.Management.Automation.Language.Ast]$Ast)

                [bool]$ReturnValue = $False
                If ($Ast -is [System.Management.Automation.Language.VariableExpressionAst]) {
                    [System.Management.Automation.Language.VariableExpressionAst]$VariableAst = $Ast
                    If (($VariableAst.VariablePath -cnotmatch '^[a-z]+([A-Za-z0-9]+)+') -or ($VariableAst.VariablePath -match '._.')) {
                        $ReturnValue = $true
                    }
                    foreach ($exception in $exceptionList) {
                        if ($VariableAst.VariablePath -like $exception) {
                            $ReturnValue = $false
                            break
                        }
                    }
                    if ($VariableAst.Parent -is [System.Management.Automation.Language.ParameterAst]) {
                        $ReturnValue = $false
                    }
                }
                return $ReturnValue
            }
            #endregion

            #region Finds ASTs that match the predicates.
            [System.Management.Automation.Language.Ast[]]$Violations = $ScriptBlockAst.FindAll($Predicate, $True)

            If ($Violations.Count -ne 0) {

                Foreach ($Violation in $Violations) {

                    $result = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        RuleName = $PSCmdlet.MyInvocation.InvocationName
                        Message = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)"
                        Extent = $Violation.Extent
                        "Severity" = "Information"
                        "SuggestedCorrections" = $null
                    }
                    $results += $result
                }
            }
            return $Results
            #endregion
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    End {}
}

Function Measure-Backtick {
    <#
    .SYNOPSIS
        Removes backticks from your script and use "splatting" instead.
    .DESCRIPTION
        Avoid using those backticks as “line continuation characters” when possible.
        To fix a violation of this rule, please remove backticks from your script and use "splatting" instead
    .EXAMPLE
        Measure-Backtick -Token $Token
    .INPUTS
        [System.Management.Automation.Language.Token[]]
    .OUTPUTS
        [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    .NOTES
        Reference: Document nested structures, Windows PowerShell Best Practices.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.Token[]]
        $Token
    )

    Process {
        $results = @()

        try {
            # Finds LineContinuation tokens
            $lcTokens = $Token | Where-Object { $PSItem.Kind -eq [System.Management.Automation.Language.TokenKind]::LineContinuation }

            foreach ($lcToken in $lcTokens) {
                $result = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    RuleName = $PSCmdlet.MyInvocation.InvocationName
                    Message = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)"
                    Extent = $lcToken.Extent
                    "Severity" = "Warning"
                    "SuggestedCorrections" = $null
                }
                $results += $result
            }

            return $results
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}


<# This seems redundant as there is a built-in rule

#>

Export-ModuleMember -Function Measure-*