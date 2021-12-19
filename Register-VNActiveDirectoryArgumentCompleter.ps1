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

        $oADSchema.FindClass($strADClassName).GetAllProperties().Where({$_.Name -like "${wordToComplete}*"}) | Sort-Object -Property Name |Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.Name,    # CompletionText
                $_.Name,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} (type '{1}'{2})" -f $_.Name, $_.Syntax, $(if (-not [System.String]::IsNullOrEmpty($_.Description)) {", description '$($_.Description)'"}))    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    ## specific cmdlets with given parameter
    Write-Output Get-ADComputer, Get-ADGroup, Get-ADOrganizationalUnit, Get-ADUser | Foreach-Object {
        Register-ArgumentCompleter -CommandName $_ -ParameterName Properties -ScriptBlock $sbPropertyNameCompleter
    } ## end Foreach-Object


    ## AD OU DN completer, searching by OU DN
    $sbOUDNCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)

        ## get OUs, supporting filtering _just_ on the OU name
        # Get-ADOrganizationalUnit -Filter {Name -like "${wordToCompleter}*"} | Foreach-Object {
        ## get OUs, supporting filtering on the OU DN itself; must be done by getting all OUs and then filtering client-side, as server-side DN filter only supports exact match, not wildcarding, seemingly
        #    and, sorting by the parent OUs, essentially, so matches are presented in "grouped-by-OU" order, for easiest recognition by consumer
        (Get-ADOrganizationalUnit -Filter * -Properties Name, DistinguishedName, whenCreated).Where({$_.DistinguishedName -like "*${wordToComplete}*"}) | Sort-Object -Property {($arrlTmp = [System.Collections.ArrayList]($_.DistinguishedName).Split(",")).Reverse(); $arrlTmp -join ","} | Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $(if ($_.DistinguishedName -match "[, ']") {'"{0}"' -f $_.DistinguishedName} else {$_.DistinguishedName}),    # CompletionText
                $_.DistinguishedName,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} (created '{1}')" -f $_.DistinguishedName, $_.whenCreated)    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    ## cmdlets with given parameter
    Write-Output SearchBase, TargetPath | Foreach-Object {
        $strThisParamName = $_
        Get-Command -Module ActiveDirectory -ParameterName $strThisParamName | ForEach-Object {Register-ArgumentCompleter -CommandName $_ -ParameterName $strThisParamName -ScriptBlock $sbOUDNCompleter}
    } ## end Foreach-Object
    ## specific Cmdlets
    ## param Path
    Register-ArgumentCompleter -CommandName (Write-Output New-ADComputer, New-ADGroup, New-ADObject, New-ADOrganizationalUnit, New-ADServiceAccount, New-ADUser) -ParameterName Path -ScriptBlock $sbOUDNCompleter
    ## param Identity
    Register-ArgumentCompleter -CommandName (Get-Command -Module ActiveDirectory -ParameterName Identity -Noun ADOrganizationalUnit).Name -ParameterName Identity -ScriptBlock $sbOUDNCompleter
}
