## Some code to help automate the updating of the ScriptInfo of a script file (will create it if it does not yet exist, too)

## path to local repo clone; used for setting/updating script file info
$strPathToRepoClone = "blah"

## for Register-VNActiveDirectoryArgumentCompleter.ps1
$oCfg = @{
	strPathToScriptFile = "$strPathToRepoClone\Register-VNActiveDirectoryArgumentCompleter.ps1"
	strPathToScriptFileInfoDatafile = "$strPathToRepoClone\ScriptFileInfoConfig_Register-VNActiveDirectoryArgumentCompleter.psd1"
}

## OR, for Register-VNAWSArgumentCompleter.ps1
$oCfg = @{
	strPathToScriptFile = "$strPathToRepoClone\Register-VNAWSArgumentCompleter.ps1"
	strPathToScriptFileInfoDatafile = "$strPathToRepoClone\ScriptFileInfoConfig_Register-VNAWSArgumentCompleter.psd1"
}

## OR, for Register-VNVMwarePowerCLIArgumentCompleter.ps1
$oCfg = @{
	strPathToScriptFile = "$strPathToRepoClone\Register-VNVMwarePowerCLIArgumentCompleter.ps1"
	strPathToScriptFileInfoDatafile = "$strPathToRepoClone\ScriptFileInfoConfig_Register-VNVMwarePowerCLIArgumentCompleter.psd1"
}



## parameters for use by both New-ScriptFileInfo and Update-ScriptFileInfo
$hshScriptInfoParams = Import-PowerShellDataFile $oCfg.strPathToScriptFileInfoDatafile

## do the actual module manifest creation/update
## create anew (so, would create a new file with just the ScriptInfo info in it, and we would add the actual script contents thereafter)
New-ScriptFileInfo -Path $oCfg.strPathToScriptFile @hshScriptInfoParams -WhatIf
## or, update the existing ScriptInfo in a script file
Update-ScriptFileInfo -Path $oCfg.strPathToScriptFile @hshScriptInfoParams -WhatIf
