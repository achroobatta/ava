#Documentation: https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/markdown/Invoke-ScriptAnalyzer.md#-settings
@{
    #CustomRulePath='path\to\CustomRuleModule.psm1'
    #RecurseCustomRulePath='path\of\customrules'
    Severity = @('Error')
    #IncludeDefaultRules=${true}
    ExcludeRules = @(
        'PSAvoidTrailingWhitespace'
    )
    #IncludeRules = @(
    #    'PSAvoidUsingWriteHost',
    #    'MyCustomRuleName'
    #)
}
