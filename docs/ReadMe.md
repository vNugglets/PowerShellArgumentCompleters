## Docs for PowerShell Arguments Completers
Some info about using argument completers.  For other info, the [ReadMe.md](../ReadMe.md) in the root of the project tells a bit of background/overview about PowerShell argument completers, and has links to further reading about how argument completers make better our daily experience in a PowerShell session.

Contents:

- [Getting Started](#gettingStarted)
- [ActiveDirectory Argument Completer quick info](#ActiveDirectory-Argument-Completer-quick-info)
- [AWS Argument Completer quick info](#AWS-Argument-Completer-quick-info)
- [VMware-PowerCLI Argument Completer quick info](#VMware-PowerCLI-Argument-Completer-quick-info)
- [Info about Argument Completers in a PowerShell Session](#infoAboutArgCompleterInPSSession)
- [Other Examples](#otherExamples)


<a id="gettingStarted"></a>
### Getting Started
To register the argument completers provided by this project, you need just a couple of things:
- the script file in which the argument completer definitions and registration statements reside (save or install it from the PowerShell Gallery)
- a PowerShell session with the given module(s) (`ActiveDirectory`, `AWS.Tools.*`, `VMware.PowerCLI`) available to it (in the `$env:PSModulePath` path, at least -- for the VMware completers, the modules don't necessarily have to be imported, yet, but for the AWS completers, only cmdlets for imported modules will be considered for arugment completers, for the sake of speed (since there are 12,000+ cmdlets in all of the AWS modules)). Note: the AWS completers will also work for the monolithic AWS modules (`AWSPowerShell` and `AWSPowerShell.NetCore`), but the way forward is to use the per-service AWS modules (provided by AWS as the `AWS.Tools.*` individual modules).

The Argument completer scripts available as a part of this project:
- `Register-VNActiveDirectoryArgumentCompleter`
- `Register-VNAWSArgumentCompleter`
- `Register-VNVMwarePowerCLIArgumentCompleter`

So, for getting/invoking any of these argument-completer scripts from the PowerShell Gallery (use the corresponding script name from above), it goes like:
``` PowerShell
## Install and invoke (if you already trust the contents)
## Install a completer script (again, specify the desired name of completer script)
Find-Script Register-VNVMwarePowerCLIArgumentCompleter | Install-Script
## or, collect 'em all! (install them all)
Find-Script Register-VN*ArgumentCompleter | Install-Script

## run the script to register argument completers
Register-VNVMwarePowerCLIArgumentCompleter.ps1


## or, Save, inspect, install, invoke
## find the script, and save it somewhere
Find-Script Register-VNVMwarePowerCLIArgumentCompleter | Save-Script -Path C:\temp\ScriptsToInspect\

## take a minute to open up the script and make sure that all is well.
#    While vNuggs is trustworthy, trust no one, right? Safety first!

## then, just run the saved script -- this registers the argument completers in the current PowerShell session
#    of course, if you Installed the script, you should just be able to call the script by name, without an explicit path
C:\temp\ScriptsToInspect\Register-VNVMwarePowerCLIArgumentCompleter.ps1
```

And, ¡voila! Now when you use the `VMware.PowerCLI` cmdlets (after connecting to a vCenter server or ESXi host), you can use \<Tab> to tab-complete names of inventory objects for parameters.

### ActiveDirectory Argument Completer quick info
The argument completers for the `ActiveDirectory` module are currently centered around object types of `Computer`, `Group`, `OrganizationalUnit`, and `User`. At least one handy thing for getting these objects is a completer for the `-Properties` parameter, since none of us remember the names of all ~401 `User` properties, or all ~189 `Group` properties, etc.

Some of the ActiveDirectory module commands for which this argument completer adds completion support:

| Name | Parameter |
| ---- | --------- |
Get-ADComputer                  | {Properties, SearchBase}
Get-ADFineGrainedPasswordPolicy | SearchBase
Get-ADGroup                     | {Identity, Properties, SearchBase}
Get-ADObject                    | SearchBase
Get-ADOptionalFeature           | SearchBase
Get-ADOrganizationalUnit        | {Identity, Properties, SearchBase}
Get-ADServiceAccount            | SearchBase
Get-ADUser                      | {Properties, SearchBase}
Move-ADObject                   | TargetPath
New-ADComputer                  | Path
New-ADGroup                     | Path
New-ADObject                    | Path
New-ADOrganizationalUnit        | Path
New-ADServiceAccount            | Path
New-ADUser                      | Path
Remove-ADOrganizationalUnit     | Identity
Restore-ADObject                | TargetPath
Search-ADAccount                | SearchBase
Set-ADOrganizationalUnit        | Identity

Quick examples of some argument tab completions for cmdlets in the ActiveDirectory module:
```PowerShell
## tab complete the names of the AD groups that start with 'vCenter_' in the given AD domain, using specified creds
Get-ADGroup -Server myotherdom -Credential $myCred vCenter_<tab>

## display an interactive list of matching AD OUs through which to navigate (arrow keys) to select the desired OU
Get-ADOrganizationalUnit groups<CTRL+Space>

```

### AWS Argument Completer quick info
As of v1.2.0 of the AWS completers, the script registers about 310 additional cmdlet/param completion combinations. A quick list of the `AWS.Tools.*` cmdlet parameters whose values can be tab-completed after registering argument completers with the given script:

- `-ApiOperation`
- `-AutoScalingGroupName`
- `-BucketName`
- `-FunctionName`
- `-LaunchConfigurationName`
- `-LogGroupName`
- `-LogGroupNamePrefix`
- `-RoleName`
- `-Service`
- `-StackName`
- ..and a few more (`Name` on some cmdlets, for example)

### VMware PowerCLI Argument Completer quick info
See the next section for how to inspect what argument completers are added by this script to what parameters/cmdlets.

<a id="infoAboutArgCompleterInPSSession"></a>
### Info about Argument Completers in a PowerShell Session
Here is a sample transcript in which the user investigated some about the Argument Completers in their PowerShell session, both before and after registering completers with the given script.

We see that there were none registered for starters, and eventually there were oodles.

``` PowerShell
PS C:\> ## have already imported VMware.PowerCLI module, say, via $Profile
PS C:\> ## let's see what argument completers are already registered (none, yet)
PS C:\> ## note: Get-ArgumentCompleter.ps1 is available from Chris Dent's Gist at
## https://gist.github.com/indented-automation/26c637fb530c4b168e62c72582534f5b
PS C:\> Get-ArgumentCompleter.ps1
PS C:\>
PS C:\> ## register some PowerCLI argument completers
PS C:\> Register-VNVMwarePowerCLIArgumentCompleter.ps1
PS C:\>
PS C:\> ## see what Parameters' values we will now be able to tab-complete!
PS C:\> ## (get argument completers are now registered, grouped by the Parameter name)
PS C:\> Get-ArgumentCompleter.ps1 | Group-Object ParameterName | Sort-Object -Property Name

Count Name                      Group
----- ----                      -----
    1 AddVMHost                 {@{CommandName=Set-VsanFaultDomain; ParameterName=AddVMHost; Definition=...
   12 Baseline                  {@{CommandName=Attach-Baseline; ParameterName=Baseline; Definition=...
   93 Cluster                   {@{CommandName=Get-HCXApplianceCompute; ParameterName=Cluster; Definition=...
    8 Datacenter                {@{CommandName=Get-Datastore; ParameterName=Datacenter; Definition=...
   33 Datastore                 {@{CommandName=New-DatastoreDrive; ParameterName=Datastore; Definition=...
    2 DatastoreCluster          {@{CommandName=Remove-DatastoreCluster; ParameterName=DatastoreCluster; Definition=...
    2 GuestID                   {@{CommandName=New-VM; ParameterName=GuestID; Definition=...
    5 HostProfile               {@{CommandName=Get-VMHostProfileImageCacheConfiguration; ParameterName=HostProfile; Definition=...
   17 Name                      {@{CommandName=Get-VM; ParameterName=Name; Definition=...
    7 OSCustomizationSpec       {@{CommandName=Get-OSCustomizationNicMapping; ParameterName=OSCustomizationSpec; Definition=...
    1 PolicyType                {@{CommandName=Set-VmcClusterEdrsPolicy; ParameterName=PolicyType; Definition=...
    9 Profile                   {@{CommandName=Apply-VMHostProfile; ParameterName=Profile; Definition=...
    1 RemoveVMHost              {@{CommandName=Set-VsanFaultDomain; ParameterName=RemoveVMHost; Definition=...
    5 ResourcePool              {@{CommandName=Get-VMHost; ParameterName=ResourcePool; Definition=...
    9 Role                      {@{CommandName=Get-PIUser; ParameterName=Role; Definition=...
  727 Server                    {@{CommandName=Apply-VMHostProfile; ParameterName=Server; Definition=...
   24 StoragePolicy             {@{CommandName=Export-SpbmStoragePolicy; ParameterName=StoragePolicy; Definition=...
   15 Template                  {@{CommandName=Get-CDDrive; ParameterName=Template; Definition=...
   11 VApp                      {@{CommandName=Export-VM; ParameterName=VApp; Definition=...
   70 VM                        {@{CommandName=Export-VM; ParameterName=VM; Definition=...
   87 VMHost                    {@{CommandName=Get-DeployMachineIdentity; ParameterName=VMHost; Definition=...

PS C:\>
PS C:\> ## see how many scenarios now have argument completers available, if we want to use them
PS C:\> Get-ArgumentCompleter.ps1 | Measure-Object

Count    : 1139
Average  :
Sum      :
Maximum  :
Minimum  :
Property :

PS C:\>
PS C:\> ## yay!
```

<a id="otherExamples"></a>
### Examples
There is a [short .gif](resources/ArgCompleterDemo_Keystrokes.gif) (displayed on top-level ReadMe for this repo, too) that depicts some use cases (pictures are worth lots of words).  Some examples typed out in words, though:

In the following line, each "\<tab>" is meant to show where pressing the \<Tab> key will cycle through the possible completion values for the corresponding parameters:
``` PowerShell
## create a new VM
New-VM -VMHost myho<tab> -ResourcePool re<tab> -Datastore ssd33<tab> -GuestId windows<tab> -OSCustomizationSpec win<tab> -StoragePolicy VVol<tab> -Server vcent<tab> -Name mynewvm0 ...

## move some VM
Move-VM dd<tab> -Datastore nas<tab> -Destination (Get-VMHost esxi0<tab>)

## get some template
Get-Template win201<tab>
```
