<#PSScriptInfo

.VERSION 1.1.1

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
Script to register PowerShell argument completers for many parameters for many VMware.PowerCLI cmdlets, making us even more productive on the command line. This enables the tab-completion of actual vSphere inventory objects' names as values to parameters to VMware.PowerCLI cmdlets -- neat!

.Example
Register-VNVMwarePowerCLIArgumentCompleter.ps1
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
        ## make the regex pattern to use for Name filtering for given View object (convert from globbing wildcard to regex pattern, to support globbing wildcard as input)
        $strNameRegex = if ($wordToComplete -match "\*") {$wordToComplete.Replace("*", ".*")} else {$wordToComplete}
        ## is this command getting Template objects? (vs. VM objects)
        $bGettingTemplate = $commandName -ne "Get-VM" -and $parameterName -ne "VM"
        Get-View -ViewType VirtualMachine -Property Name, Runtime.Powerstate -Filter @{Name = "^${strNameRegex}"; "Config.Template" = $bGettingTemplate.ToString()} | Where-Object {$fakeBoundParameter.$parameterName -notcontains $_.Name} | Sort-Object -Property Name -Unique | Foreach-Object {
            $strCompletionText = $strListItemText = if ($_.Name -match "\s") {'"{0}"' -f $_.Name} else {$_.Name}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $strListItemText,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ## for tooltip, give Name and either PowerState (for VM) or GuestFullName (for Template)
                ("{0} ({1})" -f $_.Name, $(if (-not $bGettingTemplate) {$_.Runtime.PowerState} else {$_.UpdateViewData("Config.GuestFullName"); $_.Config.GuestFullName}))    # ToolTip
            )
        } ## end foreach-object
    } ## end scriptblock

    Register-ArgumentCompleter -CommandName Get-VM, Get-Template -ParameterName Name -ScriptBlock $sbGetVmOrTemplateNameCompleter
    Write-Output VM, Template | Foreach-Object {
        ## if there are any cmdlets from any loaded modules with the given parametername, register an arg completer
        if ($arrCommandsOfInterest = Get-Command -Module ($arrModulesOfVMwarePowerCLIModule | Where-Object {$_.Name -ne "VMware.VimAutomation.Cloud"}) -ParameterName $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsOfInterest -ParameterName $_ -ScriptBlock $sbGetVmOrTemplateNameCompleter}
    } ## end ForEach-Object


    ## multiple "core" item name completer, like cluster, datacenter, hostsystem, datastore, etc.
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



    ## multiple inventory item name completer for parameters other than "-Name", like -VMHost, -Datastore, etc.
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
            ## the Tool Tip extra info
            $strToolTipExtraInfo = if ($strViewTypePerParamName -in "Datastore", "StoragePod") {
                $_.UpdateViewData("Summary.Capacity", "Summary.FreeSpace"); "{0}GB, {1}GB free" -f [Math]::Round($_.Summary.Capacity / 1GB, 1).ToString("N1"), [Math]::Round($_.Summary.FreeSpace / 1GB, 1).ToString("N1")
            } else {"'$($_.MoRef)'"}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $strListItemText,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} ({1})" -f $_.Name, $strToolTipExtraInfo)    # ToolTip
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
        } ## end switch
        & $strCommandNameToGetCompleters @hshParamForGetVIItem | Sort-Object -Property Name | Foreach-Object {
            ## make the Completion and ListItem text values; happen to be the same for now, but could be <anything of interest/value>
            $strCompletionText = $strListItemText = if ($_.Name -match "\s") {'"{0}"' -f $_.Name} else {$_.Name}
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $strCompletionText,    # CompletionText
                $strListItemText,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ## if getting OSCustSpec, include the OSCS OSType info, too; else, just the description
                ("{0} ({1}{2})" -f $_.Name, $(if ($strCommandNameToGetCompleters -eq "Get-OSCustomizationSpec") {"[$($_.OSType)] "}), $(if (-not [System.String]::isNullOrEmpty($_.Description)) {$_.Description} else {"<no description>"}))    # ToolTip
            )
        } ## end foreach-object
    } ## end scriptblock

    Write-Output Baseline, HostProfile, OSCustomizationSpec, Profile, Role, StoragePolicy | ForEach-Object {
        ## if there are any cmdlets from any loaded modules with the given parametername, register an arg completer
        if ($arrCommandsOfInterest = Get-Command -Module $arrModulesOfVMwarePowerCLIModule -ParameterName $_ -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsOfInterest -ParameterName $_ -ScriptBlock $sbGeneralVIItemNameCompleter}
    } ## end ForEach-Object
    Register-ArgumentCompleter -CommandName Get-OSCustomizationSpec, Get-PatchBaseline, Get-SpbmStoragePolicy, Get-VIRole, Get-VMHostProfile -ParameterName Name -ScriptBlock $sbGeneralVIItemNameCompleter



    ## Enum completer for enumeration values, like for -GuestID (type [VMware.Vim.VirtualMachineGuestOsIdentifier])
    $sbGuestIDEnumNameCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        ## the Enumeration type to use to get the completer values for this parameter
        $oEnumType = Switch ($parameterName) {
            GuestID {[VMware.Vim.VirtualMachineGuestOsIdentifier]}
        } ## end switch
        [System.Enum]::GetValues($oEnumType) | Select-Object -Property @{n="Name"; e = {$_.ToString()}}, value__ | Where-Object {if (-not ([System.String]::isNullOrEmpty($wordToComplete))) {$_.Name -like "${wordToComplete}*"} else {$true}} | Sort-Object -Property Name | Foreach-Object {
            ## make the Completion and ListItem text values; happen to be the same for now, but could be <anything of interest/value>
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.Name,    # CompletionText
                $_.Name,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} ({1})" -f $_.Name, $_.value__)    # ToolTip
            )
        } ## end foreach-object
    } ## end scriptblock

    Register-ArgumentCompleter -CommandName New-VM, Set-VM -ParameterName GuestID -ScriptBlock $sbGuestIDEnumNameCompleter



    ## Name completer for -Server param for cmdlets that are dealing with vCenter/VIServer (not for cmdlets where -Server is something else, like cmdlets for vROps, NSXT, HorizonView, VMC, etc.)
    $sbVIServerNameCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $global:DefaultVIServers | Where-Object {$_.Name -like "${wordToComplete}*"} | Where-Object {$fakeBoundParameter.$parameterName -notcontains $_.Name} | Sort-Object -Property Name | Foreach-Object {
            ## make the Completion and ListItem text values; happen to be the same for now, but could be <anything of interest/value>
            New-Object -TypeName System.Management.Automation.CompletionResult -ArgumentList (
                $_.Name,    # CompletionText
                $_.Name,    # ListItemText
                [System.Management.Automation.CompletionResultType]::ParameterValue,    # ResultType
                ("{0} ({1})" -f $_.Name, $_.User)    # ToolTip
            )
        } ## end foreach-object
    } ## end scriptblock

    if ($arrCommandsOfInterest = Get-Command -Module VMware.* -ParameterName Server -ErrorAction:SilentlyContinue) {Register-ArgumentCompleter -CommandName $arrCommandsOfInterest -ParameterName Server -ScriptBlock $sbVIServerNameCompleter}

    ## will need more research (are specific to a particular instance of an object, for example, or current retrieval method is sllloowww)
    ## Snapshot, PortGroup, NetworkAdapter, HardDisk, VirtualSwitch, VDPortGroup, Tag
} ## end process
