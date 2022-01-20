# Change Log for Argument Completer Scripts

## Register-VNActiveDirectoryArgumentCompleter
### v1.0.1, Jan 2022
- update to handle getting AD objects from other domains in same forest (for completing things like groups and group members)
- add `DisplayName` info to the ToolTip for some member/membership completers

### v1.0.0, Jan 2022
- initial release of argument completers -- yay!
- added completers for several parameters like `-Identity` and AD paths (`-Path`, `-SearchBase`, `-TagetPath`, etc.), and for group membership management (`-Members`, `-MemberOf`)
- added completer for arguments for parameter `-Properties` for the cmdlets `Get-ADComputer`, `Get-ADGroup`, `Get-ADOrganizationalUnit`, `Get-ADUser`, for easy discovery/specifying of choice properties to return; based on [Matt McNabb](https://mattmcnabb.github.io/)'s example from a while ago
- included helpful information in the completions' Tool Tip text, like object descriptions, types, creation information where suitable
- see [Issue #11, Add completers for ActiveDirectory module cmdlets](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/11) and the [ReadMe.md](./ReadMe.md) here for other details

## Register-VNAWSArgumentCompleter
### v1.3.1, Jan 2022
- Internal optimization/simplification of completers (feature request in [Issue #18](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/18))
### v1.3.0, Jan 2022
- Sped up registering of AWS completers (feature request in [Issue #16](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/16))
- Added argument completers for the following cmdlets/parameters (feature request in [Issue #13](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/13)):

| Parameter | NumNewCompletions | Notes |
|-----------|-------------------|-------|
`-RoleArn` | 147 | for cmdlets across several AWS services
`-RepositoryName` | 42 | for cmdlets `Get-Command -ParameterName RepositoryName -Noun ECR*`
`-RegistryId` | 46 | for cmdlets `Get-Command -ParameterName RegistryId`
`-VpcId` | 72 | and for variations of param named  `EndpointDetails_VpcId`, `VPC_VPCId`, `VpcConfig_VpcId`, `VpcConfiguration_VpcId`, `VpcId`, `VPCSettings_VpcId`
`-KeyName` | 4 | for `Get-EC2KeyPair`, `New-ASLaunchConfiguration`, `New-EC2Instance`, `Remove-EC2KeyPair`
`-GroupName` | 15 | for aguments of type IAMGroup, for cmdlets in `AWS.Tools.IdentityManagement`
`-PolicyArn` | 18 | for cmdlets in `AWS.Tools.IdentityManagement`
`-GroupId` | 14 | for noun `EC2*`; and, as a bonus feature, can type group _name_ for value of word to complete, the completer will get matching SecurityGroups, and present list of SG IDs (with tooltips that include group name)
`-UserName` | 47 | for cmdlets in `AWS.Tools.IdentityManagement`
`-MetricName` | 12 | for cmdlets in `AWS.Tools.CloudWatchLogs`, `AWS.Tools.CloudWatch`
`-NameSpace` | 10 | for cmdlets in `AWS.Tools.CloudWatchLogs`, `AWS.Tools.CloudWatch`
`-Cluster` | 32 | for cmdlets in `AWS.Tools.ECS`
`-AssociationId` | 8 | for cmdlets in `AWS.Tools.SimpleSystemsManagement`
`-VaultName` | 25 | for cmdlets in `AWS.Tools.Glacier`
`-FileSystemId` | 28 | for cmdlets in `AWS.Tools.ElasticFileSystem`, `AWS.Tools.FSx` (yes, different completion types)
`-EventBusName` | 24 | all such cmdlets are for CloudWatch Events (CWE) / EventBridge (EVB) things
`-SubnetId` | 110 | for cmdlets with variations of param named `*SubnetId*`
`DBInstanceIdentifier` | 22 | for cmdlets in at least `AWS.Tools.RDS`

### v1.2.0, Dec 2021
- added completer for arguments for parameter `-Service` for cmdlets `Get-AWSCmdletName`, `Get-AWSService` (feature request in [Issue #9](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/9))
- added completer for arguments for parameter `-ApiOperation` for cmdlet `Get-AWSCmdletName` (feature request in [Issue #9](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/9))
- added Tool Tip info for SSM Document and SSM Parameter completions (creation and last modified date, respectively)


## Register-VNVMwarePowerCLIArgumentCompleter
### v1.2.0
Updated Intellisense ToolTip value for various types to be more useful (feature request in [Issue #3](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/3)): Added more useful ToolTip values to the values in the list of possible tab completions. The list of possible completions is available when pressing `Ctrl+Space` with the cursor at the argument position, like:
```PowerShell
Get-DatastoreCluster my<Ctrl+Space>
```
Some examples of the enhanced ToolTips:
- Storage things show free/total space
- VMHost objects show the power- and connection state of the VMHost
- Templates show the configured Guest OS full name
- OSCustomization Specs show the OS type
