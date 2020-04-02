Function New-OutFilePathBase {
	<#
		.SYNOPSIS
			Build a output folder full path and file name base without extension.

		.DESCRIPTION
			Build a output folder full path and file name base without extension.  The output file name is in the form of "YYYYMMDDTHHMMSSZZZ-<ExecutionSourceName>-<CallingScriptName>[-<OutFileNameTag>]".  The calling solution is free to add a file name extension(s) (e.g. .TXT, .LOG, .CSV) as appropiate.  
			The file name consistency leverages a series of outfiles that can be systematically filtered.  The output folder full path and file name is not guaranteed to be unique, but should be unique per second.  
			The date format is sortable date/time stamp in ISO-8601:2004 basic format with no invalid file name characters (such as colon ':').  The executing computer's time zone is included in the date time stamp to support this solution's use globally.
			The -DateOffsetDays parameter can be used to reference another date relative to now.  For example, when processing yesterday's log files today, use -DateOffsetDays -1.  
			The -ExecutionSourceName parameter is either the Microsoft Exchange organization, forest, domain, computer name, or arbitrary string to support multi-client/customer use, without requiring hardcoding outfile file names.
			The calling script name is included in the outfile file name so this solution can be used by other solutions, or solution series, without requiring hardcoding outfile file names.
			OutFileNameTag is an optional comment added to the outfile file name.
			Each of the folder file path name components is provided so that calling solution can reuse them (i.e. DateTimeStamp string).  

		.COMPONENT
			System.DirectoryServices
			System.IO.Path
			CIM CIM_ComputerSystem CIM_Directory

		.PARAMETER DateOffsetDays [Int]
			Optionally specify the number of days added or subtracted from the current date.  Default is 0 days. 
			If -DateTimeLocal is specified, this offset is applied to that date as well.  
		
		.PARAMETER DateTimeLocal [String]
			Optionally specify a date time stamp string in a format that is standard for the system locale. The default (if not specified) is to use the workstation's current date and time.  
			To determine this workstation's culture enter '(Get-Culture).Name'.
			To determine this workstation's date time format enter '(Get-Culture).DateTimeFormat.ShortDatePattern' and '(Get-Culture).DateTimeFormat.ShortTimePattern'.
			If the date time string is not recognized as a valid date, the current date and time will be used.  

		.PARAMETER ExecutionSource [String]
			Specifiy the script's execution environment source.  Must be either; 'msExchOrganizationName', 'ForestName', 'DomainName', 'ComputerName', or an arbitrary string including '' or $NULL.
			If msExchOrganizationName is requested, but there is no Microsoft Exchange organization, ForestName will be used.
			If ForestName is requested, but there is no forest, DomainName will be used.  The forest name is of the executing computer's domain membership.  
			If the DomainName is requested, but the computer is not a domain member, ComputerName is used.  The domain name is of the executing computer's domain membership.  
			An arbitrary string can be used in the case where the Microsoft Exchange organization name, forest name or domain name is too generic (e.g. 'EMAIL', 'CORP' or 'ROOT').
			Defaults is msExchOrganizationName.
		
		.PARAMETER FileNameComponentDelimiter [String]
			Optional file name component delimiter.  The substitute character cannot itself be an folder or file name invalid character.  Default is hyphen '-'.

		.PARAMETER InvalidFilePathCharsSubstitute [String]
			Optionally specify which character to use to replace invalid folder and file name characters.  The substitute character cannot itself be an folder or file name invalid character.  Default is underscore '_'.

		.PARAMETER OutFileNameTag [String]
			Optional comment string added to the end of the outfile file name.

		.PARAMETER OutFolderPath [String]
			Specify which folder path to write the outfile.  Supports UNC and relative reference to the current script folder.  Except for UNC paths, this function will attempt to create and compress the output folder if it doesn’t exist.  The default is .\Reports subfolder.  

		.OUTPUTS
			An string with six custom properties:
			A string containing the ouput file path name which contains a full folder path and file name without extension.  If the folder path does exist and is not a UNC path an attempt is made to create the folder and mark it as compressed.
			FolderPath: Full outfile folder path name.
			DateTime: The DateTime object used to create the DateTimeStamp string.
			DateTimeStamp: The date/time stamp used in the outFile file name.  The sortable ISO-8601:2004 basic format includes the time zone offset from the executing computer.
			ExecutionSourceName: The execution environmental source provided or retrieved.
			ScriptFileName: Calling script file name.
			FileName: OutFile file name without an extension.

		.EXAMPLE
			To change the location where the outFile files are written to an relative path use the -OutFolderPath parameter.
			To add a comment to the file name use the -OutFileNameTag parameter.

			$outFilePathBase = New-OutFilePathBase -OutFolderPath '.\Logs' -OutFileNameTag 'TestRun#7'
			$outFilePathName = "$outFilePathBase.csv"
			$logFilePathName = "$outFilePathBase.log"

			$outFilePathName
			<CurrentLocation>\Logs\19991231T235959+1200-<MyExchangeOrgName>-<CallingScriptName>-TestRun#7.csv

			$logFilePathName
			<CurrentLocation>\Logs\19991231T235959+1200-<MyExchangeOrgName>-<CallingScriptName>-TestRun#7.log

			$outFilePathBase.FolderPath
			<CurrentLocation>\Logs\

			$outFilePathBase.DateTimeStamp
			19991231T235959+1200

			$outFilePathBase.ExecutionSourceName
			<MyExchangeOrgName>

			$outFilePathBase.ScriptFileName
			<CallingScriptName>

			$outFilePathBase.FileName
			19991231T235959+1200-<MyExchangeOrgName>-<CallingScriptName>-TestRun#7

		
		.EXAMPLE
			To change the location where the output files are written to an absolute path use the -OutFolderPath argument.
			To change the exection environment source to the domain name use the -ExecutionSource argument.

			$outFilePathBase = New-OutFilePathBase -ExecutionSource ForestName -OutFolderPath C:\Reports\

			$outFilePathBase
			C:\Reports\19991231T235959+1200-<MyForestName>-<CallingScriptName>

			$outFilePathBase.FolderPath
			C:\Reports\

			$outFilePathBase.ExecutionSourceName
			<MyForestName>

			$outFilePathBase.FileName
			19991231T235959+1200-<MyForestName>-<CallingScriptName>

		
		.EXAMPLE
			To change the location where the output files are written to an absolute path use the -OutFolderPath argument.
			To change the exection environment source to the domain name use the -ExecutionSource argument.

			$outFilePathBase = New-OutFilePathBase -ExecutionSource DomainName -OutFolderPath C:\Reports\

			$outFilePathBase
			C:\Reports\19991231T235959+1200-<MyDomainName>-<CallingScriptName>

			$outFilePathBase.FolderPath
			C:\Reports\

			$outFilePathBase.ExecutionSourceName
			<MyDomainName>

			$outFilePathBase.FileName
			19991231T235959+1200-<MyDomainName>-<CallingScriptName>

		
		.EXAMPLE
			To change the location where the output files are written to a UNC path use the -OutFolderPath argument.
			To change the exection environment source to the computer name use the -ExecutionSource argument.

			$outFilePathBase = New-OutFilePathBase -ExecutionSource ComputerName -OutFolderPath \\Server1\C$\Reports\

			$outFilePathBase
			\\Server1\C$\Reports\19991231T235959+1200-<MyComputerName>-<CallingScriptName>

			$outFilePathBase.FolderPath
			\\Server1\C$\Reports\

			$outFilePathBase.ExecutionSourceName
			<MyComputerName>

			$outFilePathBase.FileName
			19991231T235959-0600-<MyComputerName>-<CallingScriptName>

		
		.EXAMPLE
			To change the exection environment source to an arbitrary string use the -ExecutionSource argument.

			$outFilePathBase = New-OutFilePathBase -ExecutionSource 'MyOrganization'

			$outFilePathBase
			<CurrentLocation>\Reports\19991231T235959+1200-MyOrganization-<CallingScriptName>
				
			$outFilePathBase.ExecutionSourceName
			MyOrganization

			$outFilePathBase.FileName
			19991231T235959+1200-MyOrganization-<CallingScriptName>

		
		.EXAMPLE
			To change the date/time stamp to the yeterday's date, as when collecting information from yesterday's data use the -DateOffsetDays argument.

			$outFilePathBase = New-OutFilePathBase -DateOffsetDays -1

			$outFilePathBase
			<CurrentLocation>\Reports\<yesterday's date>T235959+0600-<MyExchangeOrgName>-<CallingScriptName>

			$outFilePathBase.DateTimeStamp
			<yesterday's date>T235959+1200

			$outFilePathBase.FileName
			<yesterday's date>T235959+1200-<MyExchangeOrgName>-<CallingScriptName>

		
		.EXAMPLE
			To change which charater is used to join the file name components together use the -FileNameComponentDelimiter argument.  Note the date/time stamp time zone offset component is prefixed with a plus '+' or minus '-' and is not affected by the argument.

			$outFilePathBase = New-LogFilePathBase -FileNameComponentDelimiter '_'

			$outFilePathBase
			<CurrentLocation>\Reports\19991231T235959T235959+1200_<MyExchangeOrgName>_<CallingScriptName>

			$outFilePathBase.FileName
			19991231T235959+1200_<MyExchangeOrgName>_<CallingScriptName>

		
		.EXAMPLE
			To change the character used to replace invalid folder and file name characters use the -InvalidFilePathCharsSubstitute argument.

			$outFilePathBase = New-LogFilePathBase -InvalidFilePathCharsSubstitute '#' -LogFileNameTag 'From:LocalPart@domain.com'

			$outFilePathBase
			<CurrentLocation>\Reports\19991231T235959+1200-<MyExchangeOrgName>-<CallingScriptName>-From#LocalPart@domain.com

			$outFilePathBase.FileName
			19991231T235959+1200-<MyExchangeOrgName>-<CallingScriptName>-From#LocalPart@domain.com

		.EXAMPLE
			To change the date time stamp to an arbitrary date string.

			$outFilePathBase = New-LogFilePathBase -DateTimeLocal '1/1/2001 00:00'

			$outFilePathBase
			<CurrentLocation>\Reports\20000101T000000+1200-<MyExchangeOrgName>-<CallingScriptName>.com

			$outFilePathBase.FileName
			20000101T000000+1200-<MyExchangeOrgName>-<CallingScriptName>.com

		
		.NOTES
			Author: Terry E Dow
			2013-09-12 Terry E Dow - Added support for ExecutionSource of ForestName.
			2013-09-21 Terry E Dow - Peer reviewed with the North Texas PC User Group PowerShell SIG and specific suggestion by Josh Miller.
			2013-09-21 Terry E Dow - Changed output from PSObject to String.  No longer require referencing returned object's ".Value" property.
			2018-08-21 Terry E Dow - Replaced WMIObject with equivelent CIMInstance for future proofing.  Replaced $_ with $PSItem (requires PS ver 3) for clarity.  Replaced [VOID] ... with ... > $NULL for clarity.
			2018-11-05 Terry E Dow - Fixed $MyInvocation.ScriptName vs. $Script:MyInvocation.ScriptName scope difference when dot-sourced or Import-Module.
			2018-11-05 Terry E Dow - Fixed new $OutFolderPath compression to [inherited] recursive.
			2018-11-05 Terry E Dow - Support -ExecutionSource being empty string '' or $NULL.
			2018-11-06 Terry E Dow - Replaced Add-Member with PS3's PSCustomObject.
			2018-11-06 Terry E Dow - Documentation cleanup.
			2018-11-09 Terry E Dow - Fixed ExecutionSource switch error where msExchOrganizationName won over arbitrary string.
			2020-04-01 Terry E Dow - Added parameter -DateTimeLocal which accepts a local date and time string.
			Last Modified: 2020-04-01

		.LINK
	#>
	[CmdletBinding(
		SupportsShouldProcess = $TRUE # Enable support for -WhatIf by invoked destructive cmdlets.
	)]
	Param(
		[ Parameter( HelpMessage='Specify a folder path or UNC where the output file is written.' ) ]
			[String] $OutFolderPath = '.\Reports',

		[ Parameter( HelpMessage='Optional name representing the name of the organization this script is running under.  Supported values: msExchOrganizationName, ForestName, DomainName, ComputerName, or any other arbitrary string including $NULL.' ) ]
			[String] $ExecutionSource = 'msExchOrganizationName',

		[ Parameter( HelpMessage='Optional string added to the end of the output file name.' ) ]
			[String] $OutFileNameTag = '',

		[ Parameter( HelpMessage='Optionally specify a date time stamp string in a format that is standard for the system locale.' ) ]
			[String] $DateTimeLocal = '',
		
		[ Parameter( HelpMessage='Optionally specify the number of days added or subtracted from the current date or the optionally supplied -DateTimeLocal value.' ) ]
			[Int] $DateOffsetDays = 0,

		[ Parameter( HelpMessage='Optional file name component delimiter.  The specified string cannot be an invalid file name character.' ) ]
		[ ValidateScript( { [System.IO.Path]::GetInvalidFileNameChars() -NotContains $PSItem } ) ]
			[String] $FileNameComponentDelimiter = '-',

		[ Parameter( HelpMessage='Optionally specify which character to use to replace invalid folder and file name characters.  The specified string cannot be an invalid folder or file name character.' ) ]
		[ ValidateScript( { [System.IO.Path]::GetInvalidPathChars() -NotContains $PSItem -And [System.IO.Path]::GetInvalidFileNameChars() -NotContains $PSItem } ) ]
			[String] $InvalidFilePathCharsSubstitute = '_'
	)
	
	#Requires -version 3
	Set-StrictMode -Version Latest
	
	# Detect cmdlet common parameters.
	$cmdletBoundParameters = $PSCmdlet.MyInvocation.BoundParameters
	$Debug = If ( $cmdletBoundParameters.ContainsKey('Debug') ) { $cmdletBoundParameters['Debug'] } Else { $FALSE }
	# Replace default -Debug preference from 'Inquire' to 'Continue'.
	If ( $DebugPreference -Eq 'Inquire' ) { $DebugPreference = 'Continue' }
	$Verbose = If ( $cmdletBoundParameters.ContainsKey('Verbose') ) { $cmdletBoundParameters['Verbose'] } Else { $FALSE }
	$WhatIf = If ( $cmdletBoundParameters.ContainsKey('WhatIf') ) { $cmdletBoundParameters['WhatIf'] } Else { $FALSE }
	Remove-Variable -Name cmdletBoundParameters -WhatIf:$FALSE

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Declare internal functions.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	Function Get-ComputerName {
		Write-Output (Get-CimInstance -ClassName CIM_ComputerSystem -Property Name).Name
		#Write-Output (Get-ComputerInfo -Property csName).csName # Windows PowerShell 5.1/PowerShell Core 6
	}
	
	Function Get-DomainName {
		Write-Output ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().GetDirectoryEntry()).Name
	}

	Function Get-ForestName {
		Write-Output ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).Name
	}
	
	Function Get-MsExchOrganizationName {
		$currentForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
		$rootDomainDN = $currentForest.RootDomain.GetDirectoryEntry().DistinguishedName
		$msExchConfigurationContainerSearcher = New-Object DirectoryServices.DirectorySearcher
		$msExchConfigurationContainerSearcher.SearchRoot = "LDAP://CN=Microsoft Exchange,CN=Services,CN=Configuration,$rootDomainDN"
		$msExchConfigurationContainerSearcher.Filter = '(objectCategory=msExchOrganizationContainer)'
		$msExchConfigurationContainerResult = $msExchConfigurationContainerSearcher.FindOne()
		Write-Output $msExchConfigurationContainerResult.Properties.Item('Name')
	}

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Build output folder path.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	
	# Replace invalid folder characters: "<>| and others.
	$OutFolderPath = [RegEx]::Replace( $OutFolderPath, "[$([System.IO.Path]::GetInvalidPathChars())]", $InvalidFilePathCharsSubstitute )
	Write-Debug "`$OutFolderPath:,$OutFolderPath"
	
	# Get the current path.  If invoked from a script...
	Write-Debug "`$script:MyInvocation.InvocationName:,$($script:MyInvocation.InvocationName)"
	If ( $script:MyInvocation.InvocationName ) {
		# ...get the parent script's command path.
		$currentPath = Split-Path $script:MyInvocation.MyCommand.Path -Parent
	} Else {
		# ...else get the current location.
		$currentPath = (Get-Location).Path
	}
	Write-Debug "`$currentPath:,$currentPath"
	
	# Get the full path of the combined folders of the current path and the specified output folder, which may be a relative path.
	$OutFolderPath = [System.IO.Path]::GetFullPath( [System.IO.Path]::Combine( $currentPath, $OutFolderPath ) )

	# Verify Output folder path name has trailing directory separator character.
	If ( -Not $OutFolderPath.EndsWith( [System.IO.Path]::DirectorySeparatorChar ) ) {
		$OutFolderPath += [System.IO.Path]::DirectorySeparatorChar
	}
	Write-Debug "`$OutFolderPath:,$OutFolderPath"

	# If the output folder does not exist and not a UNC path, try to create and set it to compressed recursively.
	If ( -Not ((Test-Path $OutFolderPath -PathType Container) -Or ($OutFolderPath -Match '^\\\\[^\\]+\\')) ) {
		New-Item -Path $OutFolderPath -ItemType Directory -WhatIf:$FALSE > $NULL
		Get-CimInstance -ClassName CIM_Directory -Filter "Name='$($OutFolderPath.Replace('\','\\').TrimEnd('\'))'" |
			Invoke-CimMethod -MethodName CompressEx -Arguments @{ Recursive = $TRUE } > $NULL
	}

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Build file name components.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	# Get sortable date/time stamp in ISO-8601:2004 basic format "YYYYMMDDTHHMMSSZZZ" with no invalid file name characters.
	If ( $DateTimeLocal ) {
		Try { $dateTime = (Get-Date -Date $DateTimeLocal).AddDays($DateOffsetDays) } 
		Catch { $dateTime = (Get-Date).AddDays($DateOffsetDays) }
	} Else {
		$dateTime = (Get-Date).AddDays($DateOffsetDays)
	}
	$dateTimeStamp = [RegEx]::Replace( $dateTime.ToString('yyyyMMdd\THHmmsszzz'), "[$([System.IO.Path]::GetInvalidFileNameChars())]", '' )
	Write-Debug "`$dateTimeStamp:,$dateTimeStamp"
	
	# Get execution environment source name.
	Switch ( $ExecutionSource ) {
	
		'msExchOrganizationName' {
			# Try to get current forest's Exchange organization name, else get domain or computer name.
			Try {
				$executionSourceName = Get-MsExchOrganizationName
			} Catch {
			
				# Try to get current forest name, else get computer name.
				Try {
					$executionSourceName = Get-ForestName
				} Catch {
				
					# Try to get current domain name, else get computer name.
					Try {
						$executionSourceName = Get-DomainName
					} Catch {
						$executionSourceName = Get-ComputerName
					}
				}
				
			}
			Break
		}
		
		'ForestName' {
			# Try to get current forest name, else get domain or computer name.
			Try {
				$executionSourceName = Get-ForestName
			} Catch {
			
				# Try to get current domain name, else get computer name.
				Try {
					$executionSourceName = Get-DomainName
				} Catch {
					$executionSourceName = Get-ComputerName
				}
				
			}
			Break
		}

		'DomainName' {
			# Try to get current domain name, else get computer name.
			Try {
				$executionSourceName = Get-DomainName
			} Catch {
				$executionSourceName = Get-ComputerName
			}
			Break
		}

		'ComputerName' {
			# Get current computer name.
			$executionSourceName = Get-ComputerName
			Break
		}

		{ -Not $PSItem } { # If empty string '' or $NULL
			$executionSourceName = ''
			Break
		}

		Default {
			$executionSourceName = $ExecutionSource
		}
	}
	Write-Debug "`$executionSourceName:,$executionSourceName"

	# Get current script name.
	Write-Debug "`$script:MyInvocation.ScriptName:,$($script:MyInvocation.ScriptName)"
	Write-Debug "`$MyInvocation.ScriptName:,$($MyInvocation.ScriptName)"
	If ( $Script:MyInvocation.ScriptName ) {
		$myScriptFileName = [System.IO.Path]::GetFileNameWithoutExtension( $Script:MyInvocation.ScriptName ) # Import-Module
	} Else {
		$myScriptFileName = [System.IO.Path]::GetFileNameWithoutExtension( $MyInvocation.ScriptName ) # dot-sourced
	}
	Write-Debug "`$myScriptFileName:,$myScriptFileName"
	
	Write-Debug "`$OutFileNameTag:,$OutFileNameTag"

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Build file path name without extension.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	# Join non-null file name components with delimiter.
	$outFileName =  ( $( ( $dateTimeStamp, $executionSourceName, $myScriptFileName, $OutFileNameTag ) | Where-Object { $PSItem } ) -Join $FileNameComponentDelimiter).Trim( $FileNameComponentDelimiter )
	
	# Replace invalid file name characters: "*/:<>?[\]|
	$outFileName = [RegEx]::Replace( $outFileName, "[$([System.IO.Path]::GetInvalidFileNameChars())]", $InvalidFilePathCharsSubstitute )
	Write-Debug "`$outFileName:,$outFileName"
	
	# Join folder path and file name and other information derived from this solution.
	Write-Debug "Value:,$OutFolderPath$outFileName"
	Write-Output ( [PSCustomObject] @{ 
		Value = "$OutFolderPath$outFileName"; 
		FolderPath = $OutFolderPath; 
		FileName = $outFileName; 
		DateTimeStamp = $dateTimeStamp; 
		ExecutionSourceName = $ExecutionSourceName; 
		ScriptFileName = $myScriptFileName 
	} )
}
