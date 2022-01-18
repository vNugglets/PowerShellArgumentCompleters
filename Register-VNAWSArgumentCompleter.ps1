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

    ## for all of the cmdlets with these params
    $arrAllCmdsOfInterest = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName ($arrParamNames = Write-Output AutoScalingGroupName, BucketName, FunctionName, LaunchConfigurationName, LogGroupName, LogGroupNamePrefix, RoleName, StackName) -ErrorAction:SilentlyContinue
    $arrParamNames | ForEach-Object {
        $strThisParamName = $_
        ## commands with this parameter
        $arrCommandsWithThisParam = $arrAllCmdsOfInterest.Where({$_.Parameters.ContainsKey($strThisParamName) -or ($_.Parameters.Values.Aliases -contains $strThisParamName)})
        ## if there are any commands with this param, register the arg completer for them for this param
        if (($arrCommandsWithThisParam | Measure-Object).Count -gt 0) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $strThisParamName -ScriptBlock $sbObjectNameCompleter}
    } ## end foreach-object

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



    ## completer scriptblock for -RegistryId
    $sbRegistryIdCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)

        Get-ECRRegistry | Sort-Object -Property RegistryId | Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.RegistryId    # CompletionText
            )
        } ## end Foreach-Object
    } ## end scriptblock

    Write-Output RegistryId | Foreach-Object {
        ## if there are any commands with this parameter name, register an argument completer for them
        if ($arrCommandsWithThisParam = Get-Command -ParameterName $_ -Module AWSPowerShell*, AWS.Tools.* -ErrorAction:SilentlyContinue) {
            Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $_ -ScriptBlock $sbRegistryIdCompleter
        } ## end if
    } ## end Foreach-Object



    ## Completer for things like VPCId, EC2 KeyName, lots more
    $sbMultipleObjCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)
        ## any parameters to pass on through to the Get-* cmdlet (like ProfileName, for example)
        $hshParamForGet = @{}
        if ($commandBoundParameter.ContainsKey("ProfileName")) {$hshParamForGet["ProfileName"] = $commandBoundParameter.ProfileName}

        ## strPropertyNameOfInterest:  property of returned objects that is of interest
        ## strCmdletForGet:  name of cmdlet to use to _get_ the objects to use for completing argument
        ##   or sbToGetDesiredObjects: script block for geting said objects (useful if the "getting" is more than just a cmdlet)
        ## arrPropertiesToSelect:  the properties to select for the ToolTip output (can be calculated properties)
        switch ($parameterName) {
            "AssociationId" {
                $strPropertyNameOfInterest = "AssociationId"
                $strCmdletForGet = "Get-SSMAssociationList"
                $arrPropertiesToSelect = Write-Output AssociationName AssociationVersion LastExecutionDate @{n="DocumentName"; e={$_.Name}} ScheduleExpression
                break
            }
            "Cluster" {
                $strPropertyNameOfInterest = "ClusterName"
                $sbToGetDesiredObjects = {(Get-ECSClusterList @hshParamForGet | Get-ECSClusterDetail @hshParamForGet).Clusters}
                $arrPropertiesToSelect = Write-Output ActiveServicesCount Attachments CapacityProviders RegisteredContainerInstancesCount RunningTasksCount Status
                break
            }
            "EventBusName" {
                $strPropertyNameOfInterest = "Name"
                $strCmdletForGet = "Get-EVBEventBusList"
                $arrPropertiesToSelect = Write-Output Arn
                break
            }
            "FileSystemId" {
                ## the noun prefix for the invoking command, so as to know what Get- cmdlet to use
                $strNounPrefixFromInvokingCmdlet = (($commandName.Split("-")[1]).ToCharArray() | Select-Object -First 3) -join ""
                $strPropertyNameOfInterest = "FileSystemId"
                Switch ($strNounPrefixFromInvokingCmdlet) {
                    "EFS" {
                        $strCmdletForGet = "Get-EFSFileSystem"
                        $arrPropertiesToSelect = Write-Output Name Encrypted LifeCycleState NumberOfMountTargets @{n="SizeGB"; e={$_.SizeInBytes.Value / 1GB}}
                        break
                    }
                    "FSX" {
                        $strCmdletForGet = "Get-FSXFileSystem"
                        $arrPropertiesToSelect = Write-Output FileSystemType Lifecycle @{n="StorageCapacityGB"; e={$_.StorageCapacity}} StorageType
                        break
                    }
                } ## end switch
            }
            "GroupName" {
                $strPropertyNameOfInterest = "GroupName"
                $strCmdletForGet = "Get-IAMGroupList"
                $arrPropertiesToSelect = Write-Output Arn CreateDate GroupId
            }
            "KeyName" {
                $strPropertyNameOfInterest = "KeyName"
                $strCmdletForGet = "Get-EC2KeyPair"
                $arrPropertiesToSelect = Write-Output KeyFingerprint KeyPairId KeyType
                break
            }
            "PolicyArn" {
                $strPropertyNameOfInterest = "Arn"
                $strCmdletForGet = "Get-IAMPolicyList"
                $arrPropertiesToSelect = Write-Output PolicyName DefaultVersionId UpdateDate AttachmentCount Description
                break
            }
            {$_ -match "SubnetId"} {
                $strPropertyNameOfInterest = "SubnetId"
                $strCmdletForGet = "Get-EC2Subnet"
                $arrPropertiesToSelect = Write-Output AvailabilityZone CidrBlock Ipv6Native MapCustomerOwnedIpOnLaunch MapPublicIpOnLaunch State VpcId
                break
            }
            "VaultName" {
                $strPropertyNameOfInterest = "VaultName"
                $strCmdletForGet = "Get-GLCVaultList"
                $arrPropertiesToSelect = Write-Output CreationDate LastInventoryDate NumberOfArchives SizeInBytes
                break
            }
            {$_ -match "VpcId"} {
                $strPropertyNameOfInterest = "VpcId"
                $strCmdletForGet = "Get-EC2Vpc"
                $arrPropertiesToSelect = Write-Output State CidrBlock IsDefault OwnerId
                break
            }
            "UserName" {
                $strPropertyNameOfInterest = "UserName"
                $strCmdletForGet = "Get-IAMUserList"
                $arrPropertiesToSelect = Write-Output UserId CreateDate PasswordLastUsed Path PermissionsBoundary Arn
                break
            }
        }

        $(if ($null -ne $sbToGetDesiredObjects) {& $sbToGetDesiredObjects} else {& $strCmdletForGet @hshParamForGet}) | Foreach-Object {if (-not [System.String]::IsNullOrEmpty($wordToComplete)) {if ($_.$strPropertyNameOfInterest -like "${wordToComplete}*") {$_}} else {$_}} | Sort-Object -Property $strPropertyNameOfInterest | Foreach-Object {
            $strCompletionText = if ($_.$strPropertyNameOfInterest -match "\s") {'"{0}"' -f $_.$strPropertyNameOfInterest} else {$_.$strPropertyNameOfInterest}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $_.$strPropertyNameOfInterest,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ($_ | Select-Object -Property $arrPropertiesToSelect | Format-List | Out-String)    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    ## for all of the cmdlets with parameter names like these param name wildcard strings
    $arrAllCmdsOfInterest = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName ($arrParamNames = Write-Output EndpointDetails_VpcId, VPC_VPCId, VpcConfig_VpcId, VpcConfiguration_VpcId, VpcId, VPCSettings_VpcId, Cluster, EventBusName, *SubnetId*, VaultName, FileSystemId) -ErrorAction:SilentlyContinue
    ## for each full parameter name from all the interesting cmdlets' params that are like the param wildcard from the param name array, register arg completer
    (($arrAllCmdsOfInterest.Parameters.Keys | Group-Object -NoElement).Name.Where({$strThisParamName = $_; $arrParamNames.Where({$strThisParamName -like $_})}) | Group-Object -NoElement).Name | ForEach-Object {
        $strThisParamName = $_
        ## commands with this parameter
        $arrCommandsWithThisParam = $arrAllCmdsOfInterest.Where({$_.Parameters.ContainsKey($strThisParamName) -or ($_.Parameters.Values.Aliases -contains $strThisParamName)})
        ## if there are any commands with this param, register the arg completer for them for this param
        if (($arrCommandsWithThisParam | Measure-Object).Count -gt 0) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $strThisParamName -ScriptBlock $sbMultipleObjCompleter}
    } ## end foreach-object

    ## specific cmdlets with -KeyName parameter
    Write-Output KeyName | Foreach-Object {
        ## if there are any commands with this parameter name, register an argument completer for them
        if ($arrCommandsWithThisParam = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName $_ -Name Get-EC2KeyPair, New-ASLaunchConfiguration, New-EC2Instance, Remove-EC2KeyPair -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $_ -ScriptBlock $sbMultipleObjCompleter}
    } ## end Foreach-Object

    ## SSM cmdlets with -AssociationId parameter
    Write-Output AssociationId | Foreach-Object {
        ## if there are any commands with this parameter name, register an argument completer for them
        if ($arrCommandsWithThisParam = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName $_ -Noun SSM* -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $_ -ScriptBlock $sbMultipleObjCompleter}
    } ## end Foreach-Object

    ## for all of the IAM cmdlets with parameter names like these param name wildcard strings
    $arrAllCmdsOfInterest = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName ($arrParamNames = Write-Output UserName, PolicyArn, GroupName) -ErrorAction:SilentlyContinue -Noun IAM*
    ## for each full parameter name from all the interesting cmdlets' params that are like the param wildcard from the param name array, register arg completer
    (($arrAllCmdsOfInterest.Parameters.Keys | Group-Object -NoElement).Name.Where({$strThisParamName = $_; $arrParamNames.Where({$strThisParamName -like $_})}) | Group-Object -NoElement).Name | ForEach-Object {
        $strThisParamName = $_
        ## commands with this parameter
        $arrCommandsWithThisParam = $arrAllCmdsOfInterest.Where({$_.Parameters.ContainsKey($strThisParamName) -or ($_.Parameters.Values.Aliases -contains $strThisParamName)})
        ## if there are any commands with this param, register the arg completer for them for this param
        if (($arrCommandsWithThisParam | Measure-Object).Count -gt 0) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $strThisParamName -ScriptBlock $sbMultipleObjCompleter}
    } ## end foreach-object




    ## Completer for EC2 Security Group things
    $sbSecurityGroupCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)
        ## any parameters to pass on through to the Get-* cmdlet (like ProfileName, for example)
        $hshParamForGet = @{}
        if ($commandBoundParameter.ContainsKey("ProfileName")) {$hshParamForGet["ProfileName"] = $commandBoundParameter.ProfileName}

        ## strPropertyNameOfInterest:  property of returned objects that is of interest for giving as tab-completed value
        ## arrPropertyNamesToWhichToCompare:  propert(ies) of returned objects that is of interest for determining which objects "match" the wordToCompleter
        ## strCmdletForGet:  name of cmdlet to use to _get_ the objects to use for completing argument
        ## arrPropertiesToSelect:  the properties to select for the ToolTip output (can be calculated properties)
        $strPropertyNameOfInterest = "GroupId"
        $arrPropertyNamesToWhichToCompare = Write-Output GroupId GroupName
        $strCmdletForGet = "Get-EC2SecurityGroup"
        $arrPropertiesToSelect = Write-Output GroupName Description IpPermissions Tags

        & $strCmdletForGet @hshParamForGet | Foreach-Object {
            $oThisRetrievedObj = $_
            if (-not [System.String]::IsNullOrEmpty($wordToComplete)) {
                ## if this retrieved object has a property of interest whose value is liek this wordToComplete, return it
                if ($true -in ($arrPropertyNamesToWhichToCompare | Foreach-Object {$oThisRetrievedObj.$_ -like "${wordToComplete}*"})) {$oThisRetrievedObj}
            }
            ## else, no wordToComplete, so return it
            else {$oThisRetrievedObj}
        } | Sort-Object -Property $strPropertyNameOfInterest | Foreach-Object {
            $strCompletionText = if ($_.$strPropertyNameOfInterest -match "\s") {'"{0}"' -f $_.$strPropertyNameOfInterest} else {$_.$strPropertyNameOfInterest}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $_.$strPropertyNameOfInterest,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ($_ | Select-Object -Property $arrPropertiesToSelect | Format-List | Out-String)    # ToolTip
            )
        } ## end Foreach-Object
    } ## end scriptblock

    ## specific cmdlets with -GroupId parameter
    Write-Output GroupId | Foreach-Object {
        ## if there are any commands with this parameter name, register an argument completer for them
        if ($arrCommandsWithThisParam = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName $_ -Noun EC2* -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $_ -ScriptBlock $sbSecurityGroupCompleter}
    } ## end Foreach-Object

    ## for all of the cmdlets with parameter names like these param name wildcard strings; adds ~150 completer registrations, but adds 10-20% "register args" time; worth having? Disabled for now
    # $arrAllCmdsOfInterest = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName ($arrParamNames = Write-Output AddSecurityGroupId, AmazonopensearchserviceDestinationConfiguration_VpcConfiguration_SecurityGroupIds, AwsvpcConfiguration_SecurityGroup, Ec2SecurityGroupId, EndpointDetails_SecurityGroupId, EngineSecurityGroupId, ExecutionEngine_MasterInstanceSecurityGroupId, InputSecurityGroup, InputSecurityGroupId, Instances_AdditionalMasterSecurityGroup, Instances_AdditionalSlaveSecurityGroup, Instances_EmrManagedMasterSecurityGroup, Instances_EmrManagedSlaveSecurityGroup, Instances_ServiceAccessSecurityGroup, LaunchSpecification_AllSecurityGroup, LaunchSpecification_SecurityGroupId, MetricSource_RDSSourceConfig_VpcConfiguration_SecurityGroupIdList, MetricSource_RedshiftSourceConfig_VpcConfiguration_SecurityGroupIdList, NetworkConfiguration_SecurityGroupId, NotebookInstanceSecurityGroupId, RemoveSecurityGroupId, SecurityGroup, SecurityGroupId, SecurityGroupRuleId, Vpc_SecurityGroupId, VpcConfig_SecurityGroupId, VpcConfiguration_SecurityGroup, VpcConfiguration_SecurityGroupId, VPCOptions_SecurityGroupId, VpcSecurityGroupId) -ErrorAction:SilentlyContinue
    # ## for each full parameter name from all the interesting cmdlets' params that are like the param wildcard from the param name array, register arg completer
    # (($arrAllCmdsOfInterest.Parameters.Keys | Group-Object -NoElement).Name.Where({$strThisParamName = $_; $arrParamNames.Where({$strThisParamName -like $_})}) | Group-Object -NoElement).Name.ForEach({
    #     $strThisParamName = $_
    #     ## commands with this parameter
    #     $arrCommandsWithThisParam = $arrAllCmdsOfInterest.Where({$_.Parameters.ContainsKey($strThisParamName) -or ($_.Parameters.Values.Aliases -contains $strThisParamName)})
    #     ## if there are any commands with this param, register the arg completer for them for this param
    #     if (($arrCommandsWithThisParam | Measure-Object).Count -gt 0) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $strThisParamName -ScriptBlock $sbSecurityGroupCompleter}
    # }) ## end foreach method




    ## Completer for things for which to have no toolTip (say, due to lack of interesting other properties to display)
    $sbObjCompleter_NoToolTip = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $commandBoundParameter)
        ## any parameters to pass on through to the Get-* cmdlet (like ProfileName, for example)
        $hshParamForGet = @{}
        if ($commandBoundParameter.ContainsKey("ProfileName")) {$hshParamForGet["ProfileName"] = $commandBoundParameter.ProfileName}

        ## strPropertyNameOfInterest:  property of returned objects that is of interest
        $strPropertyNameOfInterest = $parameterName  ## default here
        ## strCmdletForGet:  name of cmdlet to use to _get_ the objects to use for completing argument
        switch ($parameterName) {
            {$_ -in "MetricName", "NameSpace"} {
                $strCmdletForGet = "Get-CWMetricList"
                if ($commandBoundParameter.ContainsKey("Namespace")) {$hshParamForGet["NameSpace"] = $commandBoundParameter["NameSpace"]}
                break
            } ## end case
        } ## end switch

        & $strCmdletForGet @hshParamForGet | Foreach-Object {if (-not [System.String]::IsNullOrEmpty($wordToComplete)) {if ($_.$strPropertyNameOfInterest -like "${wordToComplete}*") {$_}} else {$_}} | Sort-Object -Property $strPropertyNameOfInterest | Foreach-Object {
            $strCompletionText = if ($_.$strPropertyNameOfInterest -match "\s") {'"{0}"' -f $_.$strPropertyNameOfInterest} else {$_.$strPropertyNameOfInterest}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList ($strCompletionText <# CompletionText #>)
        } ## end Foreach-Object
    } ## end scriptblock

    ## matching cmdlets with -MetricName, -NameSpace parameters
    Write-Output MetricName, NameSpace | Foreach-Object {
        ## if there are any commands with this parameter name, register an argument completer for them
        if ($arrCommandsWithThisParam = Get-Command -Module AWSPowerShell*, AWS.Tools.* -ParameterName $_ -Noun CW* -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsWithThisParam -ParameterName $_ -ScriptBlock $sbObjCompleter_NoToolTip}
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
