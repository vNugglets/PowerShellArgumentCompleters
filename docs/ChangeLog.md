# Change Log for Argument Completer Scripts

### Register-VNActiveDirectoryArgumentCompleter, v1.0.0, Jan 2022
- initial release of argument completers -- yay!
- added completers for several parameters like `-Identity` and AD paths (`-Path`, `-SearchBase`, `-TagetPath`, etc.), and for group membership management (`-Members`, `-MemberOf`)
- added completer for arguments for parameter `-Properties` for the cmdlets `Get-ADComputer`, `Get-ADGroup`, `Get-ADOrganizationalUnit`, `Get-ADUser`, for easy discovery/specifying of choice properties to return; based on [Matt McNabb](https://mattmcnabb.github.io/)'s example from a while ago
- included helpful information in the completions' Tool Tip text, like object descriptions, types, creation information where suitable
- see [Issue #11, Add completers for ActiveDirectory module cmdlets](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/11) and the [ReadMe.md](./ReadMe.md) here for other details

### Register-VNAWSArgumentCompleter, v1.2.0, Dec 2021
- added completer for arguments for parameter `-Service` for cmdlets `Get-AWSCmdletName`, `Get-AWSService` (feature request in [Issue #9](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/9))
- added completer for arguments for parameter `-ApiOperation` for cmdlet `Get-AWSCmdletName` (feature request in [Issue #9](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/9))
- added Tool Tip info for SSM Document and SSM Parameter completions (creation and last modified date, respectively)


### Register-VNVMwarePowerCLIArgumentCompleter, v1.2.0
Updated Intellisense ToolTip value for various types to be more useful (feature request in [Issue #3](https://github.com/vNugglets/PowerShellArgumentCompleters/issues/3)): Added more useful ToolTip values to the values in the list of possible tab completions. The list of possible completions is available when pressing `Ctrl+Space` with the cursor at the argument position, like:
```PowerShell
Get-DatastoreCluster my<Ctrl+Space>
```
Some examples of the enhanced ToolTips:
- Storage things show free/total space
- VMHost objects show the power- and connection state of the VMHost
- Templates show the configured Guest OS full name
- OSCustomization Specs show the OS type
