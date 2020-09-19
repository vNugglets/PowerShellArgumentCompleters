## Some code to help automate the updating of the ScriptInfo of a script file (will create it if it does not yet exist, too)

## for Register-VNAWSArgumentCompleter.ps1
$oCfg = @{
	strPathToScriptFile = "<pathToRepoCloneHere>\PowerShellArgumentCompleters\Register-VNAWSArgumentCompleter.ps1"
	strPathToScriptFileInfoDatafile = "<pathToRepoCloneHere>\PowerShellArgumentCompleters\ScriptFileInfoConfig_Register-VNAWSArgumentCompleter.psd1"
}

## or, for Register-VNVMwarePowerCLIArgumentCompleter.ps1
$oCfg = @{
	strPathToScriptFile = "<pathToRepoCloneHere>\PowerShellArgumentCompleters\Register-VNVMwarePowerCLIArgumentCompleter.ps1"
	strPathToScriptFileInfoDatafile = "<pathToRepoCloneHere>\PowerShellArgumentCompleters\ScriptFileInfoConfig_Register-VNVMwarePowerCLIArgumentCompleter.psd1"
}



## parameters for use by both New-ScriptFileInfo and Update-ScriptFileInfo
$hshScriptInfoParams = Import-PowerShellDataFile $oCfg.strPathToScriptFileInfoDatafile

## do the actual module manifest creation/update
## create anew (so, would create a new file with just the ScriptInfo info in it, and we would add the actual script contents thereafter)
New-ScriptFileInfo -Path $oCfg.strPathToScriptFile @hshScriptInfoParams -WhatIf
## or, update the existing ScriptInfo in a script file
Update-ScriptFileInfo -Path $oCfg.strPathToScriptFile @hshScriptInfoParams -WhatIf
