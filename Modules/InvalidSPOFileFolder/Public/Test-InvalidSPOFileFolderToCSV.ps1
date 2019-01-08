Function Test-InvalidSPOFileFolderToCSV {
	<#
				
		.SYNOPSIS
			Provided with a Get-ChildItem FileSystem path and parameters, test if the folder and file items are invalid for synchronization with OneDrive, OneDrive for Business, and SharePoint.

		.DESCRIPTION	
			The Get-ChildItem cmdlet gets the items in one or more specified locations. If the item is a container, it gets the items inside the container, known as child items. You can use the Recurse parameter to get items in all child containers.

			A location can be a file system location, such as a directory, or a location exposed by a different Windows PowerShell provider, such as a registry hive or a certificate store.
			In a file system drive, the Get-ChildItem cmdlet gets the directories, subdirectories, and files. In a file system directory, it gets subdirectories and files. 

			By default, Get-ChildItem gets non-hidden items, but you can use the Directory, File, Hidden, ReadOnly, and System parameters to get only items with these attributes. To create a complex attribute search, use the Attributes parameter. If you use these parameters, Get-ChildItem gets only the items that meet all search conditions, as though the parameters were connected by an AND operator. 

			Note: This custom cmdlet help file explains how the Get-ChildItem cmdlet works in a file system drive. For information about the Get-ChildItem cmdlet in all drives, type "Get-Help Get-ChildItem -Path $null" or see Get-ChildItem at http://go.microsoft.com/fwlink/?LinkID=113308.

		.OUTPUTS
			One output file is generated by default in a subfolder called '.\Reports\'.  The output file name is in the format of: <date/time/timezone stamp>-<msExchOrganizationContainer>-<ScriptName>.CSV.
			If parameter -Debug or -Verbose is specified, then a second file, a PowerShell transcript (*.TXT), is created with the same name and in the same location.

			The input file is read, two additional columns are added 'IsCompliant' and 'Status', and then written to the output file.  IsCompliant has a TRUE or FALSE value.  Status is either empty, or has a combined list of all non-compliance.

		.PARAMETER SpecialCharactersStateInFileFolderNamesAllowed SwitchParameter
			When enabled test for invalid characters allowed by SharePoint Server 2016 and newer.  
			When disabled test for invalid characters allowed by SharePoint Server 2013 and older.  
			Parameter alias is Legacy2013.  
		
		.PARAMETER Attributes FileAttributes
			Gets files and folders with the specified attributes. This parameter supports all attributes and lets you specify complex combinations of attributes.

			For example, to get non-system files (not directories) that are encrypted or compressed, type:
				Get-ChildItem -Attributes !Directory+!System+Encrypted, !Directory+!System+Compressed

			To find files and folders with commonly used attributes, you can use the Attributes parameter, or the Directory, File, Hidden, ReadOnly, and System switch parameters.

			The Attributes parameter supports the following attributes: Archive, Compressed, Device, Directory, Encrypted, Hidden, Normal, NotContentIndexed, Offline, ReadOnly, ReparsePoint, SparseFile, System, and Temporary. For a description of these attributes, see the FileAttributes enumeration at http://go.microsoft.com/fwlink/?LinkId=201508.

			Use the following operators to combine attributes.
				!    NOT
			   +    AND
			   ,      OR
			No spaces are permitted between an operator and its attribute. However, spaces are permitted before commas.

			You can use the following abbreviations for commonly used attributes:
				D    Directory
				H    Hidden
				R    Read-only
				S     System

		.PARAMETER Directory SwitchParameter
			Gets directories (folders).  

			To get only directories, use the Directory parameter and omit the File parameter. To exclude directories, use the File parameter and omit the Directory parameter, or use the Attributes parameter. 

			To get directories, use the Directory parameter, its "ad" alias, or the Directory attribute of the Attributes parameter.

		.PARAMETER File SwitchParameter
			Gets files. 

			To get only files, use the File parameter and omit the Directory parameter. To exclude files, use the Directory parameter and omit the File parameter, or use the Attributes parameter.

			To get files, use the File parameter, its "af" alias, or the File value of the Attributes parameter.

		.PARAMETER Hidden SwitchParameter
			Gets only hidden files and directories (folders).  By default, Get-ChildItem gets only non-hidden items, but you can use the Force parameter to include hidden items in the results.

		To get only hidden items, use the Hidden parameter, its "h" or "ah" aliases, or the Hidden value of the Attributes parameter. To exclude hidden items, omit the Hidden parameter or use the Attributes parameter.

		.PARAMETER ReadOnly SwitchParameter
			Gets only read-only files and directories (folders).  

		To get only read-only items, use the ReadOnly parameter, its "ar" alias, or the ReadOnly value of the Attributes parameter. To exclude read-only items, use the Attributes parameter.

		.PARAMETER System SwitchParameter
			Gets only system files and directories (folders).

			To get only system files and folders, use the System parameter, its "as" alias, or the System value of the Attributes parameter. To exclude system files and folders, use the Attributes parameter.

		.PARAMETER Force SwitchParameter
			Gets hidden files and folders. By default, hidden files and folder are excluded. You can also get hidden files and folders by using the Hidden parameter or the Hidden value of the Attributes parameter.

		.PARAMETER UseTransaction SwitchParameter
			Includes the command in the active transaction. This parameter is valid only when a transaction is in progress. For more information, see about_Transactions.

		.PARAMETER Depth UInt32
			{{Fill Depth Description}}

		.PARAMETER Exclude String[]
			Specifies, as a string array, an item or items that this cmdlet excludes in the operation. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as *.txt. Wildcards are permitted.

		.PARAMETER Filter String
			Specifies a filter in the provider's format or language. The value of this parameter qualifies the Path parameter. The syntax of the filter, including the use of wildcards, depends on the provider. Filters are more efficient than other parameters, because the provider applies them when retrieving the objects, rather than having Windows PowerShell filter the objects after they are retrieved.

		.PARAMETER Include String[]
			Specifies, as a string array, an item or items that this cmdlet includes in the operation. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as *.txt. Wildcards are permitted.

			The Include parameter is effective only when the command includes the Recurse parameter or the path leads to the contents of a directory, such as C:\Windows\*, where the wildcard character specifies the contents of the C:\Windows directory.

		.PARAMETER LiteralPath String[]
			Specifies, as a string arrya, a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters as escape sequences.

		.PARAMETER Name SwitchParameter
			Indicates that this cmdlet gets only the names of the items in the locations. If you pipe the output of this command to another command, only the item names are sent.

		.PARAMETER Path String[]
			Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory (.).

		.PARAMETER Recurse SwitchParameter
			Indicates that this cmdlet gets the items in the specified locations and in all child items of the locations.

			In Windows PowerShell 2.0 and earlier versions of Windows PowerShell, the Recurse parameter works only when the value of the Path parameter is a container that has child items, such as C:\Windows or C:\Windows\ , and not when it is an item does not have child items, such as C:\Windows\ .exe.

		.EXAMPLE
			Description
			-----------
			This command gets the files and subdirectories in the current directory. If the current directory does not have child items, the command does not return any results.
			Get-ChildItem

		.EXAMPLE
			Description
			-----------
			This command gets system files in the current directory and its subdirectories.
			Get-Childitem -System -File -Recurse

		.EXAMPLE
			Description
			-----------
			These command get all files, including hidden files, in the current directory, but exclude subdirectories. The second command uses aliases and abbreviations, but has the same effect as the first.
			Get-ChildItem -Attributes !Directory,!Directory+Hidden

			C:\PS> dir -att !d,!d+h

		.EXAMPLE
			Description
			-----------
			This command gets the subdirectories in the current directory. It uses the "dir" alias of the Get-ChildItem cmdlet and the "ad" alias of the Directory parameter.
			dir -ad

		.EXAMPLE
			Description
			-----------
			This command gets read-write files in the C:\ps-test directory.
			Get-ChildItem -File -Attributes !ReadOnly -path C:\ps-test

		.EXAMPLE
			Description
			-----------
			This command gets all of the .txt files in the current directory and its subdirectories. 

			The dot (.) represents the current directory. The Include parameter specifies the file name extension. The Recurse parameter directs Windows PowerShell to search for objects recursively, and it indicates that the subject of the command is the specified directory and its contents. The Force parameter adds hidden files to the display.
			get-childitem . -include *.txt -recurse -force

		.EXAMPLE
			Description
			-----------
			This command gets the .txt files in the Logs subdirectory, except for those whose names start with the letter A. It uses the wildcard character (*) to indicate the contents of the Logs subdirectory, not the directory container. Because the command does not include the Recurse parameter, Get-ChildItem does not include the contents of the current directory automatically; you need to specify it.
			get-childitem c:\windows\logs\* -include *.txt -exclude A*

		.EXAMPLE
			Description
			-----------
			This command retrieves only the names of items in the current directory.
			get-childitem -name

		.NOTE
			Author: Terry E Dow
			Creation Date: 2018-12-23
			Last Modified: 2019-01-07

			Reference:
				
	#>
	[CmdletBinding(
		SupportsShouldProcess = $TRUE # Enable support for -WhatIf by invoked destructive cmdlets.
	)]
	#[System.Diagnostics.DebuggerHidden()]
	Param(

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[String] $Attributes = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $Directory = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $File = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $Hidden = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $ReadOnly = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $System = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $Force = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $UseTransaction = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[UInt32] $Depth = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[String[]] $Exclude = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		Position=1)]
		[String] $Filter = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[String[]] $Include = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[String[]] $LiteralPath = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $Name = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		Position=0)]
		[String[]] $Path = $NULL,

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Switch] $Recurse = $NULL,
		
		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Alias('Legacy2013')]
		[Switch] $SpecialCharactersStateInFileFolderNamesAllowed = $NULL,

	#region Script Header

		[Parameter( HelpMessage='Specify the script''s execution environment source.  Must be either ''ComputerName'', ''DomainName'', ''msExchOrganizationName'' or an arbitrary string. Defaults is msExchOrganizationName.' ) ]
			[String] $ExecutionSource = $NULL,

		[Parameter( HelpMessage='Optional string added to the end of the output file name.' ) ]
			[String] $OutFileNameTag = $NULL,

		[Parameter( HelpMessage='Specify where to write the output file.' ) ]
			[String] $OutFolderPath = '.\Reports',

		[Parameter( HelpMessage='When enabled, only unhealthy items are reported.' ) ]
			[Switch] $AlertOnly = $FALSE,

		[Parameter( HelpMessage='Optionally specify the address from which the mail is sent.' ) ]
			[String] $MailFrom = $NULL,

		[Parameter( HelpMessage='Optioanlly specify the addresses to which the mail is sent.' ) ]
			[String[]] $MailTo = $NULL,

		[Parameter( HelpMessage='Optionally specify the name of the SMTP server that sends the mail message.' ) ]
			[String] $MailServer = $NULL,

		[Parameter( HelpMessage='If the mail message attachment is over this size compress (zip) it.' ) ]
			[Int] $CompressAttachmentLargerThan = 5MB
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
	# Collect script execution metrics.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	$scriptStartTime = Get-Date
	Write-Verbose "`$scriptStartTime:,$($scriptStartTime.ToString('s'))"

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Include external functions.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	#. .\New-OutFilePathBase.ps1

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Define internal functions.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8


	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Build output and log file path name.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	$outFilePathBase = New-OutFilePathBase -OutFolderPath $OutFolderPath -ExecutionSource $ExecutionSource -OutFileNameTag $OutFileNameTag

	$outFilePathName = "$($outFilePathBase.Value).csv"
	Write-Debug "`$outFilePathName: $outFilePathName"
	$logFilePathName = "$($outFilePathBase.Value).log"
	Write-Debug "`$logFilePathName: $logFilePathName"

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Optionally start or restart PowerShell transcript.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	If ( $Debug -Or $Verbose ) {
		Try {
			Start-Transcript -Path $logFilePathName -WhatIf:$FALSE
		} Catch {
			Stop-Transcript
			Start-Transcript -Path $logFilePathName -WhatIf:$FALSE
		}
	}

	#endregion Script Header

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Collect report information
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	# Validate parameters
	
	# Create Get-ChildItem hash table to splat parameters.  
	$getChildItemParameters = @{}
	If ( $Attributes ) { $getChildItemParameters.Attributes = $Attributes }
	If ( $Directory ) { $getChildItemParameters.Directory = $Directory }
	If ( $File ) { $getChildItemParameters.File = $File }
	If ( $Hidden ) { $getChildItemParameters.Hidden = $Hidden }
	If ( $ReadOnly ) { $getChildItemParameters.ReadOnly = $ReadOnly }
	If ( $System ) { $getChildItemParameters.System = $System }
	If ( $Force ) { $getChildItemParameters.Force = $Force }
	If ( $UseTransaction ) { $getChildItemParameters.UseTransaction = $UseTransaction }
	If ( $Depth ) { $getChildItemParameters.Depth = $Depth }
	If ( $Exclude ) { $getChildItemParameters.Exclude = $Exclude }
	If ( $Filter ) { $getChildItemParameters.Filter = $Filter }
	If ( $Include ) { $getChildItemParameters.Include = $Include }
	If ( $LiteralPath ) { $getChildItemParameters.LiteralPath = $LiteralPath }
	If ( $Name ) { $getChildItemParameters.Name = $Name }
	If ( $Path ) { $getChildItemParameters.Path = $Path }
	If ( $Recurse ) { $getChildItemParameters.Recurse = $Recurse }
	If ( $Debug ) {
		ForEach ( $key In $getChildItemParameters.Keys ) {
			Write-Debug "`$getChildItemParameters[$key]`:,$($getChildItemParameters[$key])"
		}
	}
	
	# Create Test-InvalidSPOFileFolder hash table to splat parameters. 
	$testInvalidSPOFileFolderParameters = @{}
	If ( $SpecialCharactersStateInFileFolderNamesAllowed ) { $testInvalidSPOFileFolderParameters.SpecialCharactersStateInFileFolderNamesAllowed = $SpecialCharactersStateInFileFolderNamesAllowed }
	If ( $Debug ) {
		ForEach ( $key In $testInvalidSPOFileFolderParameters.Keys ) {
			Write-Debug "`$testInvalidSPOFileFolderParameters[$key]`:,$($testInvalidSPOFileFolderParameters[$key])"
		}
	}
	
	# Generate report.
	Get-ChildItem @getChildItemParameters |
		Test-InvalidSPOFileFolder @testInvalidSPOFileFolderParameters | 
		Export-CSV -Path $outFilePathName -NoTypeInformation

	#region Script Footer

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Optionally mail report.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	If ( (Test-Path -PathType Leaf -Path $outFilePathName) -And $MailFrom -And $MailTo -And $MailServer ) {

		# Determine subject line report/alert mode.
		If ( $AlertOnly ) {
			$reportType = 'Alert'
		} Else {
			$reportType = 'Report'
		}

		$messageSubject = "Test OneDrive and SharePoint invalid file folder $reportType for $($outFilePathBase.ExecutionSourceName) on $((Get-Date).ToString('s'))"

		# If the out file is larger then a specified limit (message size limit), then create a compressed (zipped) copy.
		Write-Debug "$outFilePathName.Length:,$((Get-ChildItem -LiteralPath $outFilePathName).Length)"
		If ( $CompressAttachmentLargerThan -LT (Get-ChildItem -LiteralPath $outFilePathName).Length ) {

			$outZipFilePathName = "$outFilePathName.zip"
			Write-Debug "`$outZipFilePathName:,$outZipFilePathName"

			# Create a temporary empty zip file.
			Set-Content -Path $outZipFilePathName -Value ( "PK" + [Char]5 + [Char]6 + ("$([Char]0)" * 18) ) -Force -WhatIf:$FALSE

			# Wait for the zip file to appear in the parent folder.
			While ( -Not (Test-Path -PathType Leaf -Path $outZipFilePathName) ) {
				Write-Debug "Waiting for:,$outZipFilePathName"
				Start-Sleep -Milliseconds 20
			}

			# Wait for the zip file to be written by detecting that the file size is not zero.
			While ( -Not (Get-ChildItem -LiteralPath $outZipFilePathName).Length ) {
				Write-Debug "Waiting for ($outZipFilePathName\$($outFilePathBase.FileName).csv).Length:,$((Get-ChildItem -LiteralPath $outZipFilePathName).Length)"
				Start-Sleep -Milliseconds 20
			}

			# Bind to the zip file as a folder.
			$outZipFile = (New-Object -ComObject Shell.Application).NameSpace( $outZipFilePathName )

			# Copy out file into Zip file.
			$outZipFile.CopyHere( $outFilePathName )

			# Wait for the compressed file to be appear in the zip file.
			While ( -Not $outZipFile.ParseName("$($outFilePathBase.FileName).csv") ) {
				Write-Debug "Waiting for:,$outZipFilePathName\$($outFilePathBase.FileName).csv"
				Start-Sleep -Milliseconds 20
			}

			# Wait for the compressed file to be written into the zip file by detecting that the file size is not zero.
			While ( -Not ($outZipFile.ParseName("$($outFilePathBase.FileName).csv")).Size ) {
				Write-Debug "Waiting for ($outZipFilePathName\$($outFilePathBase.FileName).csv).Size:,$($($outZipFile.ParseName($($outFilePathBase.FileName).csv)).Size)"
				Start-Sleep -Milliseconds 20
			}

			# Send the report.
			Send-MailMessage `
				-From $MailFrom `
				-To $MailTo `
				-SmtpServer $MailServer `
				-Subject $messageSubject `
				-Body 'See attached zipped Excel (CSV) spreadsheet.' `
				-Attachments $outZipFilePathName

			# Remove the temporary zip file.
			Remove-Item -LiteralPath $outZipFilePathName

		} Else {

			# Send the report.
			Send-MailMessage `
				-From $MailFrom `
				-To $MailTo `
				-SmtpServer $MailServer `
				-Subject $messageSubject `
				-Body 'See attached Excel (CSV) spreadsheet.' `
				-Attachments $outFilePathName
		}
	}

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	# Optionally write script execution metrics and stop the Powershell transcript.
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

	$scriptEndTime = Get-Date
	Write-Verbose "`$scriptEndTime:,$($scriptEndTime.ToString('s'))"
	$scriptElapsedTime =  $scriptEndTime - $scriptStartTime
	Write-Verbose "`$scriptElapsedTime:,$scriptElapsedTime"
	If ( $Debug -Or $Verbose ) {
		Stop-Transcript
	}
	#endregion Script Footer
}
