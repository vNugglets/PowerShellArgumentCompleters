## some code to create Argument Completers for parameters for some of the VMware PowerCLI cmdlets

## all of the modules that are a part of the VMware.PowerCLI module; grouping by name and the selecting just the most recent version of each module (so as to avoid issue w/ using params that may have not existed in older module versions)
$arrModulesOfVMwarePowerCLIModule = (Get-Module VMware.PowerCLI -ListAvailable).RequiredModules | Group-Object -Property Name | ForEach-Object {$_.Group | Sort-Object -Property Version | Select-Object -Last 1}

## VM or template name completer
$sbGetVmOrTemplateNameCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-View -ViewType VirtualMachine -Property Name, Runtime.Powerstate -Filter @{Name = "^${wordToComplete}"; "Config.Template" = ($commandName -ne "Get-VM").ToString()} | Sort-Object -Property Name | Foreach-Object {
        New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
            $_.Name,    # CompletionText
            $_.Name,    # ListItemText
            [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
            ("{0} ({1})" -f $_.Name, $_.Runtime.PowerState)    # ToolTip
        )
    } ## end foreach-object
} ## end scriptblock

Register-ArgumentCompleter -CommandName Get-VM, Get-Template -ParameterName Name -ScriptBlock $sbGetVmOrTemplateNameCompleter


## multiple "core" item name completer, like cluster, datacenter, hostsystem, datastore
$sbGetCoreItemNameCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    ## non-exhaustive list of View items to easily grab for -Name param value completion on corresponding cmdlet
    $hshCmdletToViewType = @{
    	"Get-Cluster" = "ClusterComputeResource"
    	"Get-Datacenter" = "Datacenter"
    	"Get-Datastore" = "Datastore"
    	"Get-DatastoreCluster" = "StoragePod"
    	"Get-Folder" = "Folder"
    	"Get-ResourcePool" = "ResourcePool"
    	"Get-VDPortGroup" = "DistributedVirtualPortgroup"
    	"Get-VDSwitch" = "DistributedVirtualSwitch"
    	"Get-VApp" = "VirtualApp"
    	"Get-VMHost" = "HostSystem"
    } ## end hshtable
    ## make the regex pattern to use for Name filtering for given View object (convert from globbing wildcard to regex pattern, to support globbing wildcard as input)
    $strNameRegex = if ($wordToComplete -match "\*") {$wordToComplete.Replace("*", ".*")} else {$wordToComplete}
    ## get the possible matches, create a new CompletionResult object for each
    Get-View -ViewType $hshCmdletToViewType[$commandName] -Property Name -Filter @{Name = "^${strNameRegex}"} | Sort-Object -Property Name -Unique | Foreach-Object {
		## make the Completion and ListItem text values; happen to be the same for now, but could be <anything of interest/value>
    	$strCompletionText = $strListItemText = if ($_.Name -match "\s") {'"{0}"' -f $_.Name} else {$_.Name}
        New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
            $strCompletionText,    # CompletionText
            $strListItemText,    # ListItemText
            [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
            ("{0} ('{1}')" -f $_.Name, $_.MoRef)    # ToolTip
        )
    } ## end foreach-object
} ## end scriptblock

Register-ArgumentCompleter -CommandName Get-Cluster, Get-Datacenter, Get-Datastore, Get-DatastoreCluster, Get-Folder, Get-ResourcePool, Get-VDPortGroup, Get-VDSwitch, Get-VApp, Get-VMHost -ParameterName Name -ScriptBlock $sbGetCoreItemNameCompleter



## multiple inventory item name completer, like hostsystem, datastore; at last check, this snippet adds completers for 288 params across 238 cmdlets -- noice!
## could do datacenter, datastorecluster, cluster, vm, template, folder (InventoryLocation),
$sbGetVIItemNameCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    ## the View object type name that corresponds to the given parameter name, to be used in a Get-View call, later; defaults to the parameter name used (so as to not have to have a switch case for when a param name is the same as the View object type name; like, for example, "datastore" -- the View object type is "datastore")
    $strViewTypePerParamName = Switch ($parameterName) {
        {"VMHost", "AddVMHost", "RemoveVMHost" -contains $_} {"HostSystem"}
        "VApp" {"VirtualApp"}
        "VM" {"VirtualMachine"}
        "Cluster" {"ClusterComputeResource"}
        "DatastoreCluster" {"StoragePod"}
        default {$parameterName}
    } ## end switch
    ## make the regex pattern to use for Name filtering for given View object (convert from globbing wildcard to regex pattern, to support globbing wildcard as input)
    $strNameRegex = if ($wordToComplete -match "\*") {$wordToComplete.Replace("*", ".*")} else {$wordToComplete}
    ## get the possible matches, create a new CompletionResult object for each
    Get-View -ViewType $strViewTypePerParamName -Property Name -Filter @{Name = "^${strNameRegex}"} | Sort-Object -Property Name -Unique | Foreach-Object {
        ## make the Completion and ListItem text values; happen to be the same for now, but could be <anything of interest/value>
        $strCompletionText = $strListItemText = if ($_.Name -match "\s") {'"{0}"' -f $_.Name} else {$_.Name}
        New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
            $strCompletionText,    # CompletionText
            $strListItemText,    # ListItemText
            [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
            ("{0} ('{1}')" -f $_.Name, $_.MoRef)    # ToolTip
        )
    } ## end foreach-object
} ## end scriptblock

Write-Output AddVMHost, Cluster, Datacenter, Datastore, DatastoreCluster, RemoveVMHost, ResourcePool, VApp, VM, VMHost | Foreach-Object {
    ## if there are any cmdlets from any loaded modules with the given parametername, register an arg completer
    if ($arrCommandsOfInterest = Get-Command -Module $arrModulesOfVMwarePowerCLIModule -ParameterName $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsOfInterest -ParameterName $_ -ScriptBlock $sbGetVIItemNameCompleter}
} ## end ForEach-Object



## VIRole name completer
$sbVIRoleNameCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-VIRole | Sort-Object -Property Name | Foreach-Object {
        New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
            $_.Name,    # CompletionText
            $_.Name,    # ListItemText
            [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
            ("{0} ({1})" -f $_.Name, $_.Description)    # ToolTip
        )
    } ## end foreach-object
} ## end scriptblock

Register-ArgumentCompleter -CommandName (Get-Command -Module VMware.VimAutomation.Core -ParameterName Role) -ParameterName Role -ScriptBlock $sbVIRoleNameCompleter
