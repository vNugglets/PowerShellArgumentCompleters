# Change Log for Argument Completer Scripts

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
