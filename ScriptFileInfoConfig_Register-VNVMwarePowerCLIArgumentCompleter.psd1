## config file for creating/update PowerShell ScriptInfo for given script file (via the New-ScriptFileInfo, Update-ScriptFileInfo cmdlets)
## for script Register-VNVMwarePowerCLIArgumentCompleter.ps1
@{
	Version = "1.3.0"
	Author = "Matt Boren (@mtboren)"
	CompanyName = 'vNugglets'
	Copyright = "MIT License"
	Description = "Script to register PowerShell argument completers for many parameters for many VMware.PowerCLI cmdlets, making us even more productive on the command line. This enables the tab-completion of actual vSphere inventory objects' names as values to parameters to VMware.PowerCLI cmdlets -- neat!"
	IconUri = "https://avatars0.githubusercontent.com/u/22530966"
	LicenseUri = "https://github.com/vNugglets/PowerShellArgumentCompleters/blob/main/License"
	ProjectUri = "https://github.com/vNugglets/PowerShellArgumentCompleters"
	ReleaseNotes = "See ReadMe and other docs at https://github.com/vNugglets/PowerShellArgumentCompleters"
	Tags = "vNugglets", "PowerShell", "ArgumentCompleter", "Parameter", "VMware", "PowerCLI", "AdminOptimization", "NaturalExperience", "TabComplete", "TabCompletion", "Completion", "Awesome"
	# RequiredModules
	# ExternalModuleDependencies
	# RequiredScripts
	# ExternalScriptDependencies
	# PrivateData
	Verbose = $true
} ## end hashtable