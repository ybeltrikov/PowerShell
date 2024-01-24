#no longer needed as there is a built-in rule
#want to keep it for reference

Function Measure-DoubleQuoteString {
    <#
    .SYNOPSIS
        Only use double quotes in expandable strings
    .DESCRIPTION
        Avoid using those double quotes in static strings.
        To fix a violation of this rule, please replace double quotes with single ones
    .EXAMPLE
        Measure-DoubleQuoteString -ScriptBlockAst $ScriptBlockAst
    .INPUTS
        [System.Management.Automation.Language.Token[]]
    .OUTPUTS
        [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    .NOTES
        Reference: Windows PowerShell Best Practices.
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
                If ($Ast -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
                    $quoteType = $Ast.Extent.Text[0]
                    If (($quoteType -eq '"') -and ($Ast -notmatch '\$\(?')) {
                        $ReturnValue = $True
                    }
                }
                return $ReturnValue
            }
            #endregion

            #region Finds ASTs that match the predicates.
            [System.Management.Automation.Language.Ast[]]$Violations = $ScriptBlockAst.FindAll($Predicate, $True)

            If ($violations.Count -ne 0) {

                Foreach ($violation in $violations) {

                    $correctedCode = $violation.Extent.Text.Replace('"', "'")
                    [int]$startLineNumber = $violation.Extent.StartLineNumber
                    [int]$endLineNumber = $violation.Extent.EndLineNumber
                    [int]$startColumnNumber = $violation.Extent.StartColumnNumber
                    [int]$endColumnNumber = $violation.Extent.EndColumnNumber
                    [string]$correction = $correctedCode
                    [string]$file = $MyInvocation.MyCommand.Definition
                    [string]$optionalDescription = 'Replace double quotes with single ones'
                    $objParams = @{
                        TypeName = 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent'
                        ArgumentList = $startLineNumber, $endLineNumber, $startColumnNumber,
                                       $endColumnNumber, $correction, $file, $optionalDescription
                    }
                    $correctionExtent = New-Object @objParams
                    $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection[$($objParams.TypeName)]
                    $suggestedCorrections.add($correctionExtent) | Out-Null

                    $result = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        RuleName = $PSCmdlet.MyInvocation.InvocationName
                        Message = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)"
                        Extent = $violation.Extent
                        "Severity" = "Information"
                        #TODO: add code for suggested correction
                        "SuggestedCorrections" = $suggestedCorrections
                    }
                    $results += $result
                }
            }
            return $results
            #endregion
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}
