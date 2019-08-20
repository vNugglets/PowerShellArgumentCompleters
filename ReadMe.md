## Argument Completers for some PowerShell module cmdlets

A collection of some PowerShell argument completers for various cmdlets, starting with those in the VMware PowerShell module `VMware.PowerCLI`.

## Getting Started
The [docs](./docs) for this project have the information about getting started with using argument completers. Check them out.

## Deeper Info

Background: PowerShell argument completers are a way to enable tab-completion of cmdlet parameter values.  One can use a scriptblock of goodness in order to generate the completion results.  So, for example:
``` PowerShell
## with a proper argument completer for the -Name parameter, the following cycles through VMs whose name match the given string, live, from the given virtual infrastructure
Get-VM -Name matt<tab>
```
By registering an argument completer scriptblock for a particular cmdlet and parameter, at tab-completion time, that completer generates a list of completion results (assuming any matches), through which the user can subsequently cycle via further `Tab`-ing.  The workflow:
- register argument completer scriptblock for a cmdlet/parameter pair (say, by runnig a script that has argument completers in it, and that registers them for cmdlet/parameter pairs)
- for a registered argument completer, the argument scriptblock is executed one time for the first press of the `Tab` key, creating a list of completion results (if any)
- each subsequent press of `Tab` cycles through the list of completions results (assuming that there is more than one)
- one can also see the whole list of completion results, assuming they are in an environment that supports such things, like in something with IntelliSense, or in a PowerShell session with the `PSReadline` module loaded

A bit deeper explanation on the behavior resides at [https://github.com/mtboren/PowerCLIFeedback/blob/master/PowerCLISuggestions.md](https://github.com/mtboren/PowerCLIFeedback/blob/master/PowerCLISuggestions.md) in the "Support Natural PowerShell Interactive Behavior" section

For a bit more information about PowerShell argument completers (though there is not extensive official documentation on argument completers themselves to be found, yet), see [Register-ArgumentCompleter
](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter)