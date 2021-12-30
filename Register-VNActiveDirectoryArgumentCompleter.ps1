
<#PSScriptInfo

.VERSION 1.0.0

.GUID d7c13ce3-a513-4a05-8093-8e098a7e9557

.AUTHOR Matt Boren (@mtboren)

.COMPANYNAME vNugglets

.COPYRIGHT MIT License

.TAGS vNugglets PowerShell ArgumentCompleter Parameter ActiveDirectory AD AdminOptimization NaturalExperience TabComplete TabCompletion Completion Awesome

.LICENSEURI https://github.com/vNugglets/PowerShellArgumentCompleters/blob/main/License

.PROJECTURI https://github.com/vNugglets/PowerShellArgumentCompleters

.ICONURI https://avatars0.githubusercontent.com/u/22530966

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
See ReadMe and other docs at https://github.com/vNugglets/PowerShellArgumentCompleters

.PRIVATEDATA

#>

#Requires -Module ActiveDirectory

<#

.DESCRIPTION
Script to register PowerShell argument completers for many parameters of ActiveDirectory module cmdlets, making us even more productive on the command line. This enables the tab-completion of actual ActiveDirectory objects' and properties' names as values to parameters to ActiveDirectory cmdlets -- neat!

#>

Param()



process {
    ## AD object property name completer
    $sbPropertyNameCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

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
                ("[{0}] {1} (description of '{2}')" -f $_.Syntax, $_.Name, $_.Description)    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    ## specific cmdlets with given parameter
    Write-Output Get-ADComputer, Get-ADGroup, Get-ADOrganizationalUnit, Get-ADUser | Foreach-Object {
        Register-ArgumentCompleter -CommandName $_ -ParameterName Properties -ScriptBlock $sbPropertyNameCompleter
    } ## end Foreach-Object


    ## AD OU DN completer, searching by OU DN
    $sbOUDNCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        ## get OUs, supporting filtering _just_ on the OU name
        # Get-ADOrganizationalUnit -Filter {Name -like "${wordToCompleter}*"} | Foreach-Object {
        ## get OUs, supporting filtering on the OU DN itself; must be done by getting all OUs and then filtering client-side, as server-side DN filter only supports exact match, not wildcarding, seemingly
        #    and, sorting by the parent OUs, essentially, so matches are presented in "grouped-by-OU" order, for easiest recognition by consumer
        $hshParmForGetADOU = @{Filter = "*"; Properties = "Name", "DistinguishedName", "whenCreated", "Description"}
        ## if these other params are specified to the command, pass them through
        Write-Output Credential Server | Foreach-Object {
            if ($fakeBoundParameter.ContainsKey($_)) {$hshParmForGetADOU[$_] = $fakeBoundParameter.$_}
        }
        (Get-ADOrganizationalUnit @hshParmForGetADOU).Where({$_.DistinguishedName -like "*${wordToComplete}*"}) | Sort-Object -Property {($arrlTmp = [System.Collections.ArrayList]($_.DistinguishedName).Split(",")).Reverse(); $arrlTmp -join ","} | Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $(if ($_.DistinguishedName -match "[, ']") {'"{0}"' -f $_.DistinguishedName} else {$_.DistinguishedName}),    # CompletionText
                $_.DistinguishedName,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} (created '{1}', description of '{2}')" -f $_.DistinguishedName, $_.whenCreated, $_.Description)    # ToolTip
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


    ## AD Group name (Identity) completer
    $sbGroupIdentityCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        $hshParmForGetADGroup = @{Filter = "Name -like '${wordToComplete}*'"; Properties = "Name", "Description"}
        ## if these other params are specified to the command, pass them through
        Write-Output Credential Server | Foreach-Object {
            if ($fakeBoundParameter.ContainsKey($_)) {$hshParmForGetADGroup[$_] = $fakeBoundParameter.$_}
        }
        Get-ADGroup @hshParmForGetADGroup | Sort-Object -Property Name | Foreach-Object {
            $strCompletionText = if ($_.Name -match "\s") {'"{0}"' -f $_.Name} else {$_.Name}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $_.Name,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} ({1} {2} group, description of '{3}')" -f $_.DistinguishedName, $_.GroupScope, $_.GroupCategory, $_.Description)    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock
    Register-ArgumentCompleter -CommandName (Write-Output Get-ADGroup) -ParameterName Identity -ScriptBlock $sbGroupIdentityCompleter
}
