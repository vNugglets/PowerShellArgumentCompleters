<#PSScriptInfo

.VERSION 1.0.0

.GUID 3290ce71-109f-486d-8f58-49eb21d6c334

.AUTHOR Matt Boren (@mtboren)

.COMPANYNAME vNugglets

.COPYRIGHT MIT License

.TAGS vNugglets PowerShell ArgumentCompleter Parameter VMware PowerCLI AdminOptimization NaturalExperience TabComplete TabCompletion Completion

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
Script to register PowerShell argument completers for many parameters for many VMware.PowerCLI cmdlets, making us even more productive on the command line.  This enables the tab-completion of actual vSphere inventory objects' names as values to parameters to VMware.PowerCLI cmdlets -- neat!

.Example
Register-VNVMwarePowerCLIArgCompleter.ps1
Register argument completers for all of the VMware.PowerCLI cmdlets that are currently available in this PowerShell session, and for which there is an argument completer defined in this script

.Link
https://vNugglets.com
https://github.com/vNugglets
Register-ArgumentCompleter
VMware.PowerCLI module
#>

Param()

process {
    ## all of the modules that are a part of the VMware.PowerCLI module; grouping by name and the selecting just the most recent version of each module (so as to avoid issue w/ using params that may have not existed in older module versions)
    $arrModulesOfVMwarePowerCLIModule = (Get-Module VMware.PowerCLI -ListAvailable).RequiredModules | Group-Object -Property Name | ForEach-Object {$_.Group | Sort-Object -Property Version | Select-Object -Last 1}

    ## VM or template name completer
    $sbGetVmOrTemplateNameCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-View -ViewType VirtualMachine -Property Name, Runtime.Powerstate -Filter @{Name = "^${wordToComplete}"; "Config.Template" = ($commandName -ne "Get-VM" -and $parameterName -ne "VM").ToString()} | Sort-Object -Property Name | Foreach-Object {
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.Name,    # CompletionText
                $_.Name,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} ({1})" -f $_.Name, $_.Runtime.PowerState)    # ToolTip
            )
        } ## end foreach-object
    } ## end scriptblock

    Register-ArgumentCompleter -CommandName Get-VM, Get-Template -ParameterName Name -ScriptBlock $sbGetVmOrTemplateNameCompleter
    Write-Output VM, Template | Foreach-Object {
        ## if there are any cmdlets from any loaded modules with the given parametername, register an arg completer
        if ($arrCommandsOfInterest = Get-Command -Module ($arrModulesOfVMwarePowerCLIModule | Where-Object {$_.Name -ne "VMware.VimAutomation.Cloud"}) -ParameterName $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsOfInterest -ParameterName $_ -ScriptBlock $sbGetVmOrTemplateNameCompleter}
    } ## end ForEach-Object


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



    ## multiple inventory item name completer, like hostsystem, datastore
    $sbGetVIItemNameCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        ## the View object type name that corresponds to the given parameter name, to be used in a Get-View call, later; defaults to the parameter name used (so as to not have to have a switch case for when a param name is the same as the View object type name; like, for example, "datastore" -- the View object type is "datastore")
        $strViewTypePerParamName = Switch ($parameterName) {
            {"VMHost", "AddVMHost", "RemoveVMHost" -contains $_} {"HostSystem"}
            "VApp" {"VirtualApp"}
            "Cluster" {"ClusterComputeResource"}
            "DatastoreCluster" {"StoragePod"}
            default {$parameterName}  ## gets things like Datacenter, ResourcePool
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

    Write-Output AddVMHost, Cluster, Datacenter, Datastore, DatastoreCluster, RemoveVMHost, ResourcePool, VMHost | Foreach-Object {
        ## if there are any cmdlets from any loaded modules with the given parametername, register an arg completer
        if ($arrCommandsOfInterest = Get-Command -Module $arrModulesOfVMwarePowerCLIModule -ParameterName $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsOfInterest -ParameterName $_ -ScriptBlock $sbGetVIItemNameCompleter}
    } ## end ForEach-Object
    if ($arrCommandsOfInterest = Get-Command -Module ($arrModulesOfVMwarePowerCLIModule | Where-Object {$_.Name -ne "VMware.VimAutomation.Cloud"}) -ParameterName VApp -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsOfInterest -ParameterName VApp -ScriptBlock $sbGetVIItemNameCompleter}



    ## Name completer for multiple things; Get-VIRole, Get-VMHostProfile
    $sbGeneralVIItemNameCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $hshParamForGetVIItem = @{}
        if (-not [System.String]::isNullOrEmpty($wordToComplete)) {$hshParamForGetVIItem['Name'] = "${wordToComplete}*"}
        ## the PowerCLI cmdlet name to use to get the completer values for this parameter
        $strCommandNameToGetCompleters = Switch ($parameterName) {
            Baseline {"Get-Baseline"}
            {"HostProfile", "Profile" -contains $_} {"Get-VMHostProfile"}
            Name {$commandName} ## if it's -Name param, use the $commandName that is for this invocation
            OSCustomizationSpec {"Get-OSCustomizationSpec"}
            Role {"Get-VIRole"}
            StoragePolicy {"Get-SpbmStoragePolicy"}
        } ## end hsh
        & $strCommandNameToGetCompleters @hshParamForGetVIItem | Sort-Object -Property Name | Foreach-Object {
            ## make the Completion and ListItem text values; happen to be the same for now, but could be <anything of interest/value>
            $strCompletionText = $strListItemText = if ($_.Name -match "\s") {'"{0}"' -f $_.Name} else {$_.Name}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $strListItemText,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} ({1})" -f $_.Name, $_.Description)    # ToolTip
            )
        } ## end foreach-object
    } ## end scriptblock

    Write-Output Baseline, HostProfile, OSCustomizationSpec, Profile, Role, StoragePolicy | ForEach-Object {
        ## if there are any cmdlets from any loaded modules with the given parametername, register an arg completer
        if ($arrCommandsOfInterest = Get-Command -Module $arrModulesOfVMwarePowerCLIModule -ParameterName $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsOfInterest -ParameterName $_ -ScriptBlock $sbGeneralVIItemNameCompleter}
    } ## end ForEach-Object
    Register-ArgumentCompleter -CommandName Get-OSCustomizationSpec, Get-PatchBaseline, Get-SpbmStoragePolicy, Get-VIRole, Get-VMHostProfile -ParameterName Name -ScriptBlock $sbGeneralVIItemNameCompleter


    ## will need more research (are specific to a particular instance of an object, for example, or current retrieval method is sllloowww)
    ## Snapshot, PortGroup, NetworkAdapter, HardDisk, VirtualSwitch, VDPortGroup, Tag
} ## end process
