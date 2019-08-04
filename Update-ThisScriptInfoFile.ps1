<#	.Description
	Some code to help automate the updating of the ScriptInfo of a script file (will create it if it does not yet exist, too)
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
	## Path to scriptfile with whose scriptinfo to deal
	[String]$Path = "Register-VMwarePowerCLIArgCompleter.ps1",

	## Recreate the manifest (overwrite with full, fresh copy instead of update?)
	[Switch]$Recreate,

	## Force the ScriptFileInfo?  Useful for, say, when given script file does not already have scriptfileinfo in it
	[Switch]$Force
)
begin {
	$strModuleName = "vNugglets.VDNetworking"
	$strModuleFolderFilespec = "$PSScriptRoot\$strModuleName"
	$strFilespecForPsd1 = Join-Path $strModuleFolderFilespec "${strModuleName}.psd1"

	## parameters for use by both New-ScriptFileInfo and Update-ScriptFileInfo
	$hshScriptInfoParams = @{
		# Confirm = $true
		Path = $Path
		Version = "1.0.0"
		Author = "Matt Boren (@mtboren)"
		CompanyName = 'vNugglets'
		Copyright = "MIT License"
		Description = "Script to register PowerShell argument completers for many parameters for many VMware.PowerCLI cmdlets, making us even more productive on the command line"
		IconUri = "https://avatars0.githubusercontent.com/u/22530966"
		LicenseUri = "https://github.com/vNugglets/PowerShellArgumentCompleters/blob/master/License"
		ProjectUri = "https://github.com/vNugglets/PowerShellArgumentCompleters"
		ReleaseNotes = "See ReadMe and other docs at https://github.com/vNugglets/PowerShellArgumentCompleters"
		Tags = Write-Output vNugglets PowerShell ArgumentCompleter Parameter VMware PowerCLI AdminOptimization NaturalExperience TabComplete TabCompletion Completion
		# RequiredModules
		# ExternalModuleDependencies
		# RequiredScripts
		# ExternalScriptDependencies
		# PrivateData
		# Verbose = $true
		Force = $Force
	} ## end hashtable
} ## end begin

process {
	$bScriptFileAlreadyExists = Test-Path -Path $Path
	$strMsgForShouldProcess = "{0} ScriptFile info" -f $(if ((-not $bScriptFileAlreadyExists) -or $Recreate) {"Create"} else {"Update"})
	if ($PsCmdlet.ShouldProcess("script '$Path'", $strMsgForShouldProcess)) {
		## do the actual module manifest creation/update
		if ((-not $bScriptFileAlreadyExists) -or $Recreate) {Microsoft.PowerShell.Core\New-ScriptFileInfo @hshScriptInfoParams}
		else {PowerShellGet\Update-ScriptFileInfo @hshScriptInfoParams}
		## replace the comment in the resulting module manifest that includes "PSGet_" prefixed to the actual module name with a line without "PSGet_" in it
		# (Get-Content -Path $strFilespecForPsd1 -Raw).Replace("# Module manifest for module 'PSGet_$strModuleName'", "# Module manifest for module '$strModuleName'") | Set-Content -Path $strFilespecForPsd1
	} ## end if
} ## end process
