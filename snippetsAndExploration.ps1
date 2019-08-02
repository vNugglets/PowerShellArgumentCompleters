## some snippets from exploring things

## get the parameter names for the given cmdlets
(Get-Command -Module (Get-Module VMware.PowerCLI -ListAvailable).RequiredModules).Parameters | Foreach-Object {$_.Getenumerator()} | Group-Object -Proper key -OutVariable arrParamNameGroups
## see how cmdlets use each param; useful to know on which param names to focus
$arrParamNameGroups | Sort-Object -Property Count, name
