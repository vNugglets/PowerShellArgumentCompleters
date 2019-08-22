## Docs for PowerShell Arguments Completers
Some info about using argument completers.  For other info, the [ReadMe.md](../ReadMe.md) in the root of the project tells a bit of background/overview about PowerShell argument completers, and has links to further reading about how argument completers make better our daily experience in a PowerShell session.

Contents:

- [Getting Started](#gettingStarted)
- [Info about Argument Completers in a PowerShell Session](#infoAboutArgCompleterInPSSession)
- [Other Examples](#otherExamples)


<a id="gettingStarted"></a>
### Getting Started
To register the argument completers provided by this project, you need just a couple of things:
- the script file in which the argument completer definitions and registration statements reside (save or install it from the PowerShell Gallery)
- a PowerShell session with the `VMware.PowerCLI` module available to it (in the `$env:PSModulePath` path, at least -- doesn't necessarily have to be imported, yet)

So, like:
``` PowerShell
## find the script, and save it somewhere; alternatively, you could use Install-Script to just install it somewhere in your scripts path straight-away
Find-Script Register-VNVMwarePowerCLIArgumentCompleter | Save-Script -Path c:\temp\ScriptsToInspect\

## take a minute to open up the script and make sure that all is well.  While vNuggs is trustworthy, trust no one, right? Safety first!

## then, just run the saved script -- this registers the argument completers in the current PowerShell session; of course, if you Installed the script, you should just be able to call the script by name, without an explicit path
c:\temp\ScriptsToInspect\Register-VNVMwarePowerCLIArgumentCompleter.ps1
```

And, ¡voila! Now when you use the `VMware.PowerCLI` cmdlets (after connecting to a vCenter server or ESXi host), you can use \<Tab> to tab-complete names of inventory objects for parameters.

A quick list of the `VMware.PowerCLI` cmdlet parameters whose values can be tab-completed after registering argument completers with this script:

- `-Cluster`
- `-Datacenter`
- `-Datastore`
- `-DatastoreCluster`
- `-GuestID`
- `-HostProfile`
- `-Name`
- `-OSCustomizationSpec`
- `-Profile`
- `-ResourcePool`
- `-Role`
- `-Server`
- `-StoragePolicy`
- `-Template`
- `-VApp`
- `-VM`
- `-VMHost`

<a id="infoAboutArgCompleterInPSSession"></a>
### Info about Argument Completers in a PowerShell Session
Here is a sample transcript in which the user investigated some about the Argument Completers in their PowerShell session, both before- and after registering completers with the given script.

We see that there were none registered for starters, and eventually there were oodles.

``` PowerShell
PS C:\> ## have already imported VMware.PowerCLI module, say, via $Profile
PS C:\> ## let's see what argument completers are already registered (none, yet)
PS C:\> Get-ArgumentCompleter.ps1
PS C:\>
PS C:\> ## register some PowerCLI argument completers
PS C:\> Register-VNVMwarePowerCLIArgumentCompleter.ps1
PS C:\>
PS C:\> ## see what Parameters' values we will now be able to tab-complete!
PS C:\> ## (get argument completers are now registered, grouped by the Parameter name)
PS C:\> Get-ArgumentCompleter.ps1 | Group-Object ParameterName | Sort-Object -Property Name

Count Name                  Group
----- ----                  -----
    1 AddVMHost             {@{CommandName=Set-VsanFaultDomain; ParameterName=AddVMHost; Definition=...
   12 Baseline              {@{CommandName=Attach-Baseline; ParameterName=Baseline; Definition=...
   36 Cluster               {@{CommandName=Get-Datacenter; ParameterName=Cluster; Definition=...
    8 Datacenter            {@{CommandName=Get-Datastore; ParameterName=Datacenter; Definition=...
   26 Datastore             {@{CommandName=New-DatastoreDrive; ParameterName=Datastore; Definition=...
    2 DatastoreCluster      {@{CommandName=Remove-DatastoreCluster; ParameterName=DatastoreCluster; Definition=...
    2 GuestID               {@{CommandName=New-VM; ParameterName=GuestID; Definition=...
    5 HostProfile           {@{CommandName=Get-VMHostProfileImageCacheConfiguration; ParameterName=HostProfile; ...
   17 Name                  {@{CommandName=Get-VM; ParameterName=Name; Definition=...
    7 OSCustomizationSpec   {@{CommandName=Get-OSCustomizationNicMapping; ParameterName=OSCustomizationSpec; Def...
    9 Profile               {@{CommandName=Apply-VMHostProfile; ParameterName=Profile; Definition=...
    1 RemoveVMHost          {@{CommandName=Set-VsanFaultDomain; ParameterName=RemoveVMHost; Definition=...
    5 ResourcePool          {@{CommandName=Get-VMHost; ParameterName=ResourcePool; Definition=...
    7 Role                  {@{CommandName=Get-PIUser; ParameterName=Role; Definition=...
  372 Server                {@{CommandName=Apply-VMHostProfile; ParameterName=Server; Definition=...
   18 StoragePolicy         {@{CommandName=Export-SpbmStoragePolicy; ParameterName=StoragePolicy; Definition=...
   13 Template              {@{CommandName=Get-CDDrive; ParameterName=Template; Definition=...
    9 VApp                  {@{CommandName=Export-VM; ParameterName=VApp; Definition=...
   63 VM                    {@{CommandName=Export-VM; ParameterName=VM; Definition=...
   76 VMHost                {@{CommandName=Get-DeployMachineIdentity; ParameterName=VMHost; Definition=...

PS C:\>
PS C:\> ## see how many scenarios now have argument completers available, if we want to use them
PS C:\> Get-ArgumentCompleter.ps1 | Measure-Object

Count    : 689
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
New-VM -VMHost myho<tab> -ResourcePool re<tab> -Datastore ssd33<tab> -GuestId windows<tab>  -OSCustomizationSpec win<tab> -StoragePolicy VVol<tab> -Server vcent<tab> -Name mynewvm0 ...

## move some VM
Move-VM dd<tab> -Datastore nas<tab> -Destination (Get-VMHost esxi0<tab>)

## get some template
Get-Template win201<tab>
```
