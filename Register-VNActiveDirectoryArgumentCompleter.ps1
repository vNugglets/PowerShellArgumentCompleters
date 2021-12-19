#Requires -Module ActiveDirectory

Param()

process {
    ## AD object property name completer
    $sbPropertyNameCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)

        ## get the AD schema for the default AD forest; used to get given object class and its properties
        $oADSchema = [DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetSchema([System.DirectoryServices.ActiveDirectory.DirectoryContext]::new([System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Forest, (Get-ADForest)))
        $strADClassName = Switch ($commandName) {
            "Get-ADComputer" {"computer"}
            "Get-ADGroup" {"group"}
            "Get-ADOrganizationalUnit" {"organizationalUnit"}
            "Get-ADUser" {"user"}
        }

        $oADSchema.FindClass($strADClassName).GetAllProperties().Where({$_.Name -like "${wordToComplete}*"}) | Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.Name,    # CompletionText
                $_.Name,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} (type '{1}'{2})" -f $_.Name, $_.Syntax, $(if (-not [System.String]::IsNullOrEmpty($_.Description)) {", description '$($_.Description)'"}))    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    ## specific cmdlets with -Service parameter
    Write-Output Get-ADComputer, Get-ADGroup, Get-ADOrganizationalUnit, Get-ADUser | Foreach-Object {
        if (Get-Command -Name $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $_ -ParameterName Properties -ScriptBlock $sbPropertyNameCompleter}
    } ## end Foreach-Object
}
