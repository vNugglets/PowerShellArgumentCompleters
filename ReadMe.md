## Argument Completers for some PowerShell module cmdlets

A collection of some PowerShell argument completers for various cmdlets, starting with those in the VMware PowerShell module `VMware.PowerCLI`.

Background: PowerShell argument completers are a way to enable tab-completion of cmdlet parameter values.  One can use a scriptblock of goodness in order to generate the completion results.  So, for example:
``` PowerShell
## with a proper argument completer for the -Name parameter, the following cycles through VMs whose name match the given string, live, from the given virtual infrastructure
Get-VM -Name matt<tab>
```

A bit deeper explanation resides at [https://github.com/mtboren/PowerCLIFeedback/blob/master/PowerCLISuggestions.md](https://github.com/mtboren/PowerCLIFeedback/blob/master/PowerCLISuggestions.md) in the "Support Natural PowerShell Interactive Behavior" section

For a bit more information about PowerShell argument completers (though there is not extensive official documentation on argument completers themselves to be found), see [Register-ArgumentCompleter
](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter)