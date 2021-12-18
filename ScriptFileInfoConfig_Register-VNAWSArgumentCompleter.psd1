## config file for creating/update PowerShell ScriptInfo for given script file (via the New-ScriptFileInfo, Update-ScriptFileInfo cmdlets)
## for script Register-VNVMwarePowerCLIArgumentCompleter.ps1
@{
	Version = "1.2.0"
	Author = "Matt Boren (@mtboren)"
	CompanyName = 'vNugglets'
	Copyright = "MIT License"
	Description = "Script to register PowerShell argument completers for many parameters for many AWS.Tools.* (and AWSPowerShell*) cmdlets, making us even more productive on the command line. This enables the tab-completion of actual AWS inventory objects' names as values to parameters to AWS cmdlets -- neat!"
	IconUri = "https://avatars0.githubusercontent.com/u/22530966"
	LicenseUri = "https://github.com/vNugglets/PowerShellArgumentCompleters/blob/master/License"
	ProjectUri = "https://github.com/vNugglets/PowerShellArgumentCompleters"
	ReleaseNotes = "See ReadMe and other docs at https://github.com/vNugglets/PowerShellArgumentCompleters"
	Tags = "vNugglets", "PowerShell", "ArgumentCompleter", "Parameter", "AWS", "Amazaon", "AmazonWebServices", "AdminOptimization", "NaturalExperience", "TabComplete", "TabCompletion", "Completion"
	# RequiredModules
	# ExternalModuleDependencies
	# RequiredScripts
	# ExternalScriptDependencies
	# PrivateData
	Verbose = $true
} ## end hashtable