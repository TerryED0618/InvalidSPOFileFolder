# Generic PowerShell module to import PS1 files into current session.  
# Attribution: http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/

# Get public and private function definition files.
$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.PS1  -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.PS1 -ErrorAction SilentlyContinue )

# Dot source each of the PS1 files.
ForEach ( $import In @( $public + $private ) ) {
	Try {
		. $import.fullname
	} Catch {
		Write-Error -Message "Failed to import function $($import.FullName): $PSItem"
	}
}

# Export Public functions
# Rely on PSD1's FunctionsToExport (recommended) or include the following:
# Export-ModuleMember -Function $Public.BaseName