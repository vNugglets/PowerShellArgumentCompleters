<# .Description
	Create/Update the ScriptInfo of a script file (will create it if it does not yet exist)
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
	## The completer script whose Script Info to update/create
	[Parameter(Mandatory = $true)][ValidateSet("ActiveDirectory", "AWS", "VMwarePowerCLI")][String[]]$CompleterType,

	## Force the update of Script File Info in the given script file? Useful for an existing script that has no Script File Info, yet
	[Switch]$Force
)

process {
	$CompleterType | ForEach-Object {
		$oCfg = @{
			strPathToScriptFile = "$PSScriptRoot\Register-VN${_}ArgumentCompleter.ps1"
			strPathToScriptFileInfoDatafile = "$PSScriptRoot\ScriptFileInfoConfig_Register-VN${_}ArgumentCompleter.psd1"
		}
		## parameters for use by both New-ScriptFileInfo and Update-ScriptFileInfo
		$hshScriptInfoParams = Import-PowerShellDataFile $oCfg.strPathToScriptFileInfoDatafile
		$hshScriptInfoParams["Path"] = $oCfg.strPathToScriptFile

		$strCmdletNameForScriptFileInfoAction, $strVerbForShouldProcessMessage = if (Test-Path $oCfg.strPathToScriptFile) {
			## script file already exists, so update it
			"Update-ScriptFileInfo", "Update"
			## if -Force was specified, use it
			if ($Force.IsPresent) {$hshScriptInfoParams["Force"] = $true}
		} else {
			## else, will create anew
			"New-ScriptFileInfo", "Create"
		}

		## do the actual module manifest creation/update
		if ($PSCmdlet.ShouldProcess($hshScriptInfoParams["Path"], "$strVerbForShouldProcessMessage Script Information")) {
			## update the existing ScriptInfo in a script file, or create anew (so, would create a new file with just the ScriptInfo info in it, and we would add the actual script contents thereafter)
			& $strCmdletNameForScriptFileInfoAction @hshScriptInfoParams
		}
	}
}
