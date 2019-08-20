## Docs for PowerShell Arguments Completers
Some info about using argument completers.  For other info, the [ReadMe.md](../ReadMe.md) in the root of the project tells a bit of background/overview about PowerShell argument completers, and has links to further reading about how argument completers make better our daily experience in a PowerShell session.

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

So, for example, in the following line, each "\<tab>" is meant to show where pressing the \<Tab> key will cycle through the possible completion values for the corresponding parameters:
``` PowerShell
## create a new VM
New-VM -VMHost myho<tab> -ResourcePool re<tab> -Datastore ssd33<tab> -GuestId windows<tab>  -OSCustomizationSpec win<tab> -StoragePolicy VVol<tab> -Server vcent<tab> -Name mynewvm0 ...

## move some VM
Move-VM dd<tab> -Datastore nas<tab> -Destination (Get-VMHost esxi0<tab>)

## get some template
Get-Template win201<tab>
```
