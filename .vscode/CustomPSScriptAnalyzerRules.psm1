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

            $Results = @()

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
                            RuleName               = $PSCmdlet.MyInvocation.InvocationName
                            Message                = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)"
                            Extent                 = $Violation.Extent
                            "Severity"             = "Information"
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
    
            Process {
    
                $Results = @()
    
                try {
                    #region Define predicates to find ASTs.
    
                    [ScriptBlock]$Predicate = {
                        Param ([System.Management.Automation.Language.Ast]$Ast)
    
                        [bool]$ReturnValue = $False
                        If ($Ast -is [System.Management.Automation.Language.AssignmentStatementAst]) {
    
                            [System.Management.Automation.Language.AssignmentStatementAst]$VariableAst = $Ast
                            If (($VariableAst.Left.VariablePath.UserPath -cnotmatch '^[a-z]+([A-Za-z0-9]+)+') -or ($VariableAst.Left.VariablePath.UserPath -cmatch '_')) {
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
                                RuleName               = $PSCmdlet.MyInvocation.InvocationName
                                Message                = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)"
                                Extent                 = $Violation.Extent
                                "Severity"             = "Information"
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
    

Export-ModuleMember -Function Measure-*
