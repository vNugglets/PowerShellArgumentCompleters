<#PSScriptInfo

.VERSION 1.2.0

.GUID bc73fa4a-6436-4524-b722-e7b3a98fdfac

.AUTHOR Matt Boren (@mtboren)

.COMPANYNAME vNugglets

.COPYRIGHT MIT License

.TAGS vNugglets PowerShell ArgumentCompleter Parameter AWS Amazaon AmazonWebServices AdminOptimization NaturalExperience TabComplete TabCompletion Completion

.LICENSEURI https://github.com/vNugglets/PowerShellArgumentCompleters/blob/master/License

.PROJECTURI https://github.com/vNugglets/PowerShellArgumentCompleters

.ICONURI https://avatars0.githubusercontent.com/u/22530966

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
See ReadMe and other docs at https://github.com/vNugglets/PowerShellArgumentCompleters

.PRIVATEDATA

#>



<#

.DESCRIPTION
Script to register PowerShell argument completers for many parameters for many AWS.Tools.* (and AWSPowerShell*) cmdlets, making us even more productive on the command line. This enables the tab-completion of actual AWS inventory objects' names as values to parameters to AWS cmdlets -- neat!

.Example
Register-VNAWSArgumentCompleter.ps1
Register argument completers for all of the AWS PowerShell cmdlets that are currently available in this PowerShell session, and for which there is an argument completer defined in this script

.Link
https://vNugglets.com
https://github.com/vNugglets
Register-ArgumentCompleter
AWS PowerShell modules
#>

Param()

process {
    ## Object name completer
    $sbObjectNameCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)
        ## any parameters to pass on through to the Get-* cmdlet (like ProfileName, for example)
        $hshParamForGet = @{}
        if ($commandBoundParameter.ContainsKey("ProfileName")) {$hshParamForGet["ProfileName"] = $commandBoundParameter.ProfileName}

        ## the property of returned objects that is of interest
        $strPropertyNameOfInterest = $parameterName  ## the property name that corrsponds to the
        $strPropertyNameOfInterest_CreationDate = "CreationDate"  ## the property name that corresponds to when the object was created (not consistent across all objects)
        ## string to include in tooltip for creation / last modified text
        $strAddlInfoDescriptor = "created"
        $strCmdletForGet = Switch ($parameterName) {
        	"AutoScalingGroupName" {"Get-ASAutoScalingGroup"; $strPropertyNameOfInterest_CreationDate = "CreatedTime"}
        	"BucketName" {"Get-S3Bucket"}
            "FunctionName" {"Get-LMFunctionList"}
            "LaunchConfigurationName" {"Get-ASLaunchConfiguration"; $strPropertyNameOfInterest_CreationDate = "CreatedTime"}
            {"LogGroupName", "LogGroupNamePrefix" -contains $_} {"Get-CWLLogGroup"; $strPropertyNameOfInterest = "LogGroupName"; $strPropertyNameOfInterest_CreationDate = "CreationTime"}
            "Name" {
                $strPropertyNameOfInterest_CreationDate = "CreatedTime"
                ## return the name of the cmdlet to use for getting list of arg completers, and optionally set other things
                Switch ($commandName) {
                    "Get-ELB2LoadBalancer" {$commandName; $strPropertyNameOfInterest = "LoadBalancerName"}
                    "Get-ELB2TargetGroup" {$commandName; $strPropertyNameOfInterest = "TargetGroupName"}
                    "Get-SSMDocument" {"Get-SSMDocumentList"; $strPropertyNameOfInterest_CreationDate = "CreatedDate"}
                    {"Get-SSMParameter", "Get-SSMParameterHistory" -contains $_} {"Get-SSMParameterList"; $strPropertyNameOfInterest_CreationDate = "LastModifiedDate"; $strAddlInfoDescriptor = "last modified"}
                    default {$commandName}
                } ## end inner switch
            } ## end case
        	"RoleName" {"Get-IAMRoleList"; $strPropertyNameOfInterest_CreationDate = "CreateDate"}
            "StackName" {"Get-CFNStack"; $strPropertyNameOfInterest_CreationDate = "CreationTime"}
        }
        & $strCmdletForGet @hshParamForGet | Foreach-Object {if (-not [System.String]::IsNullOrEmpty($wordToComplete)) {if ($_.$strPropertyNameOfInterest -like "${wordToComplete}*") {$_}} else {$_}} | Sort-Object -Property $strPropertyNameOfInterest | Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.$strPropertyNameOfInterest,    # CompletionText
                $_.$strPropertyNameOfInterest,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0}{1}" -f $_.$strPropertyNameOfInterest, $(if ($_ | Get-Member -Name $strPropertyNameOfInterest_CreationDate) {" ($strAddlInfoDescriptor $($_.$strPropertyNameOfInterest_CreationDate))"}))    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    Write-Output AutoScalingGroupName, BucketName, FunctionName, LaunchConfigurationName, LogGroupName, LogGroupNamePrefix, RoleName, StackName | Foreach-Object {
        ## if there are any commands with this parameter name, register an argument completer for them
        if ($arrCommandsWithThisParam = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $_ -ScriptBlock $sbObjectNameCompleter}
    } ## end Foreach-Object

    ## specific cmdlets with -Name parameter
    Write-Output Get-ELB2LoadBalancer, Get-ELB2TargetGroup, Get-SSMDocument, Get-SSMParameter, Get-SSMParameterHistory | Foreach-Object {
        if (Get-Command -Name $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $_ -ParameterName Name -ScriptBlock $sbObjectNameCompleter}
    } ## end Foreach-Object


    ## ARN completer
    $sbARNCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)
        ## any parameters to pass on through to the Get-* cmdlet (like ProfileName, for example)
        $hshParamForGet = @{}
        if ($commandBoundParameter.ContainsKey("ProfileName")) {$hshParamForGet["ProfileName"] = $commandBoundParameter.ProfileName}

        ## the property of returned objects that is of interest
        $strPropertyNameOfInterest = "Arn"  ## the property name that corrsponds to the
        $strPropertyNameOfInterest_CreationDate = "CreateDate"  ## the property name that corresponds to when the object was created (not consistent across all objects)
        ## string to include in tooltip for creation / last modified text
        $strAddlInfoDescriptor = "Created"
        $strCmdletForGet = Switch ($parameterName) {
            "RoleArn" {"Get-IAMRoleList"; break}
        }
        & $strCmdletForGet @hshParamForGet | Foreach-Object {if (-not [System.String]::IsNullOrEmpty($wordToComplete)) {if ($_.$strPropertyNameOfInterest -like "${wordToComplete}*") {$_}} else {$_}} | Sort-Object -Property $strPropertyNameOfInterest | Foreach-Object {
            $strCompletionText = if ($_.$strPropertyNameOfInterest -match "\s") {'"{0}"' -f $_.$strPropertyNameOfInterest} else {$_.$strPropertyNameOfInterest}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $_.$strPropertyNameOfInterest,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ([PSCustomObject][Ordered]@{$strAddlInfoDescriptor = $_.$strPropertyNameOfInterest_CreationDate; Description = $_.Description} | Format-List | Out-String)    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    Write-Output RoleArn | Foreach-Object {
        ## if there are any commands with this parameter name, register an argument completer for them
        if ($arrCommandsWithThisParam = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $_ -ScriptBlock $sbARNCompleter}
    } ## end Foreach-Object



    ## ECR Repository completer
    $sbECRRepositoryCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)
        ## any parameters to pass on through to the Get-* cmdlet (like ProfileName, for example)
        $hshParamForGet = @{}
        if ($commandBoundParameter.ContainsKey("ProfileName")) {$hshParamForGet["ProfileName"] = $commandBoundParameter.ProfileName}

        ## the property of returned objects that is of interest
        $strPropertyNameOfInterest = "RepositoryName"  ## the property name that corrsponds to the
        $strPropertyNameOfInterest_CreationDate = "CreatedAt"  ## the property name that corresponds to when the object was created (not consistent across all objects)
        ## string to include in tooltip for creation / last modified text
        $strAddlInfoDescriptor = "CreatedAt"
        $strCmdletForGet = "Get-ECRRepository"

        & $strCmdletForGet @hshParamForGet | Foreach-Object {if (-not [System.String]::IsNullOrEmpty($wordToComplete)) {if ($_.$strPropertyNameOfInterest -like "${wordToComplete}*") {$_}} else {$_}} | Sort-Object -Property $strPropertyNameOfInterest | Foreach-Object {
            $strCompletionText = if ($_.$strPropertyNameOfInterest -match "\s") {'"{0}"' -f $_.$strPropertyNameOfInterest} else {$_.$strPropertyNameOfInterest}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $_.$strPropertyNameOfInterest,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ([PSCustomObject][Ordered]@{RepositoryUri = $_.RepositoryUri; $strAddlInfoDescriptor = $_.$strPropertyNameOfInterest_CreationDate} | Format-List | Out-String)    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    Write-Output RepositoryName | Foreach-Object {
        ## if there are any commands with this parameter name, register an argument completer for them
        if ($arrCommandsWithThisParam = Get-Command -ParameterName $_ -Noun ECR* -Module AWSPowerShell*, AWS.Tools.* -ErrorAction:SilentlyContinue) {
            Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $_ -ScriptBlock $sbECRRepositoryCompleter
        } ## end if
    } ## end Foreach-Object



    ## completer scriptblock for -Service
    $sbServiceCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)

        Get-AWSService | Foreach-Object {
            ## if no wordToComplete provided, or this item is like wordToComplete, use it
            if (
                [System.String]::IsNullOrEmpty($wordToComplete) -or
                $_.Service -like "${wordToComplete}*"
            ) {$_}
        } | Sort-Object -Property Service | Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.Service,    # CompletionText
                $_.Service,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} ({1}{2})" -f $_.Service, $_.ServiceName, $(if ($_ | Get-Member -Name ModuleName) {", module '$($_.ModuleName)'"}))    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    ## specific cmdlets with -Service parameter
    Write-Output Get-AWSCmdletName, Get-AWSService | Foreach-Object {
        if (Get-Command -Name $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $_ -ParameterName Service -ScriptBlock $sbServiceCompleter}
    } ## end Foreach-Object


    ## completer scriptblock for -ApiOperation
    $sbApiOperationCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)

        $hshParamFOrGetAWSCmdletName = @{ApiOperation = $wordToComplete.Trim("*"); MatchWithRegex = $true}

        Get-AWSCmdletName @hshParamFOrGetAWSCmdletName | Sort-Object -Property ServiceName, CmdletName | Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.ServiceOperation,    # CompletionText
                $_.ServiceOperation,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} (for service '{1}')" -f $_.ServiceOperation, $_.ServiceName)    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    ## specific cmdlets with -ApiOperation parameter
    Write-Output Get-AWSCmdletName | Foreach-Object {
        if (Get-Command -Name $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $_ -ParameterName ApiOperation -ScriptBlock $sbApiOperationCompleter}
    } ## end Foreach-Object
}
