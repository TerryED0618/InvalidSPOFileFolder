Function Test-InvalidSPOFileFolder {
	<#
	.SYNOPSIS
		Test if a FileSystem item is invalid for synchronization with OneDrive, OneDrive for Business, and SharePoint.
	
	.DESCRIPTION
		Provided a FileSystem's DirectoryInfo or FileInfo item (from Get-ChildItem or Get-Item) determine if the item's metadata is invalid for synchronition with OneDrive, OneDrive for Business, and SharePoint.  

	.PARAMETER ItemInfo [DirectoryInfo] or [FileInfo]
		A FileSystem item either of type DirectoryInfo or FileInfo.  
	
	.PARAMETER SpecialCharactersStateInFileFolderNamesAllowed SwitchParameter
		When enabled test for invalid characters allowed by SharePoint Server 2016 and newer.  
		When disabled test for invalid characters allowed by SharePoint Server 2013 and older.  
		Parameter alias is Legacy2013.  
	
	.EXAMPLE
		Get-ChildItem -Path C:\Users\<UserName>\Documents -Recurse |
			Test-InvalidSPOFileFolder | 
			Export-CSV -Path '.\Test-InvalidSPOFileFolder.csv'
	
	.NOTE
		Author: Terry E Dow
		Creation Date: 2018-12-23
		Last Updated: 2019-01-07

		Reference:
		# Invalid file names and file types in OneDrive, OneDrive for Business, and SharePoint
		# https://support.office.com/en-us/article/invalid-file-names-and-file-types-in-onedrive-onedrive-for-business-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa?ui=en-US&rs=en-US&ad=US#invalidcharacters
	#>
	[CmdletBinding(
		SupportsShouldProcess = $TRUE # Enable support for -WhatIf by invoked destructive cmdlets.
	)]
	#[System.Diagnostics.DebuggerHidden()]
	Param(

		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[ValidateScript( { ( 'DirectoryInfo', 'FileInfo' ) -Contains $PSItem.GetType().Name } )]
		$ItemInfo,
		
		[Parameter(
		ValueFromPipeline=$TRUE,
		ValueFromPipelineByPropertyName=$TRUE )]
		[Alias('Legacy2013')]
		[Switch] $SpecialCharactersStateInFileFolderNamesAllowed = $NULL
		
	)

	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	Begin {
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

		# Initialize metrics
		$totalCount = 0
		$totalCountFile = 0
		$totalCountDirectory = 0
		$totalSize = 0
		$totalInvalid = 0
		$maxFullNameLength = 0

		
		# Define restrictions
		If ( $SpecialCharactersStateInFileFolderNamesAllowed ) {
			# RegEx Esc Char . $ ^ { [ ( | ) * + ? \
			
			# " * : < > ? / \ |
			$invalidCharactersPattern = [RegEx] '["|\*|:|<|>|\?|/|\\|\|]'
		} Else {
			# ~ " # % & * : < > ? / \ { | }.
			$invalidCharactersPattern = [RegEx] '[~|"|#|%|&|\*|:|<|>|\?|/|\\|{|\||}]'
		}
		
		# 2.2.57 UNC https://msdn.microsoft.com/en-us/library/gg465305.aspx
		# "\\" host-name "\" share-name  [ "\" object-name ]
		$UNCPathPattern = [RegEx] '\\\\[^\*\\]{1,16}' # NetBIOS Name https://msdn.microsoft.com/en-us/library/dd891456.aspx
		$FileSystemPattern = [RegEx] '[A-Z]:'
		$InvalidFileName = @( '.lock', 'CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9', '_vti_', 'desktop.ini' )
		$InvalidFileNameStartsWith = [RegEx] '^[~|\$]'
		$InvalidFolderName = @( '_vti_', 'forms' )
		$BlockedFileType = @( '.pst', '.one' ) 
		$FullNameMaxLength = 400 #  OneDrive, OneDrive for Business and SharePoint Online 400; SharePoint Server versions 260
		$FileMaxSize = 32GB # OneDrive 35GB; OneDrive for Business 15GB
		$FileMaxCount = 100000 
		
	}
	
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	Process {
	
		# Get FileSystem item's metadata.
		Write-Debug "`$ItemInfo.GetType().Name:,$($ItemInfo.GetType().Name)"
		$baseName = $ItemInfo.BaseName
		Write-Debug "`$baseName:,$baseName"
		#$directory = $ItemInfo.Directory
		#Write-Debug "`$directory:,$directory"
		$extension = $ItemInfo.Extension
		Write-Debug "`$extension:,$extension"
		$fullName = $ItemInfo.FullName
		Write-Debug "`$fullName:,$fullName"
		Try { $length = $ItemInfo.Length } Catch { $length = 0 }
		Write-Debug "`$length:,$length"
		$name = $ItemInfo.Name
		Write-Debug "`$name:,$name"
		$isContainer = $ItemInfo.PSIsContainer
		Write-Debug "`$isContainer:,$isContainer"
		#$fileName = $ItemInfo.VersionInfo.FileName
		#Write-Debug "`$fileName:,fileName"
		
		# Collect metrics
		$totalCount++
		$totalSize += $length
		
		# Initialize metrics. 		
		$isInvalid = $FALSE
		$isInvalidCharacter = $FALSE
		$isInvalidFolderName = $FALSE
		$isInvalidFileName = $FALSE
		$isBlockedFileType = $FALSE
		$isInvalidFileSize = $FALSE
		$isInvalidFileCount = $FALSE
		$isInvalidFullNameLength = $FALSE
		$isNetwork = $FALSE
		$isMappedDrive = $FALSE
		$status = ''
		$newName = $Name
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Invalid characters
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		If ( $name -Match $invalidCharactersPattern ) { 
			$isInvalid = $TRUE
			$totalInvalid++
			$isInvalidCharacter = $TRUE
			$status = (( $status, " Invalid Character" ) -Join ';').Trim(';')
			
			If ( $SpecialCharactersStateInFileFolderNamesAllowed ) {	
				$newName = $newName -Replace '[#]', 'Num'
				$newName = $newName -Replace '[%]', 'Pct'
				$newName = $newName -Replace '[&]', 'And'
				$newName = $newName -Replace '[{]', '('
				$newName = $newName -Replace '[}]', ')'
				$newName = $newName -Replace '[~]', '-'
			} Else {
				$newName = $newName -Replace '["]', ''''
				$newName = $newName -Replace '[#]', 'Num'
				$newName = $newName -Replace '[%]', 'Pct'
				$newName = $newName -Replace '[&]', 'And'
				$newName = $newName -Replace '[\*]', '+' #
				$newName = $newName -Replace '[/]', '_'
				$newName = $newName -Replace '[:]', ';'
				$newName = $newName -Replace '[<]', '('
				$newName = $newName -Replace '[>]', ')'
				$newName = $newName -Replace '[?]', '!'
				$newName = $newName -Replace '[\\]', '_' #
				$newName = $newName -Replace '[{]', '('
				$newName = $newName -Replace '[\|]', '!' #
				$newName = $newName -Replace '[}]', ')'
				$newName = $newName -Replace '[~]', '-'
			}
			
			Write-Debug "`$newName:,$newName"
		}
				
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Invalid file or folder names
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		# Is folder or file?
		If ( $isContainer ) {
			$totalCountDirectory++
			If ( $invalidFolderName -Contains $name ) { 
				$isInvalid = $TRUE
				$totalInvalid++
				$isInvalidFolderName = $TRUE
				$status = (( $status, " Invalid FolderName '$name'" ) -Join ';').Trim(';')
				
				$newName = "-$newName-" 
			}		
		} Else {
			$totalCountFile++
			If ( $invalidFileName -Contains $name -Or $name -Match $invalidFileNameStartsWith ) {
				$isInvalid = $TRUE
				$totalInvalid++
				$isInvalidFileName = $TRUE
				$status = (( $status, " Invalid FileName '$name'" ) -Join ';').Trim(';')
				
				$newName = "-$newName-" 
			}
		}

		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Invalid or blocked file types
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

		If ( $blockedFileType -Contains $extension ) { 
			$isInvalid = $TRUE
			$totalInvalid++
			$isBlockedFileType = $TRUE
			$status = (( $status, " Blocked FileType" ) -Join ';').Trim(';')
		}
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Network or mapped drives
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

		# If UNC path
		If ( $fullName -Match $UNCPathPattern ) { 
			$isInvalid = $TRUE
			$totalInvalid++
			$isNetwork = $TRUE
			$status = (( $status, " Network" ) -Join ';').Trim(';')
		}
		
		# If FileSystem device type is Network
		Write-Debug ( Get-CimInstance Win32_LogicalDisk -Filter "DeviceId='$($fullName[0]):'" ).DriveType
		IF ( $fullName -CMatch $FileSystemPattern -And (( Get-CimInstance Win32_LogicalDisk -Filter "DeviceId='$($fullName[0]):'" ).DriveType -EQ 4) ) { # DriveType Network = 4
			$isInvalid = $TRUE
			$totalInvalid++
			$isMappedDrive = $TRUE
			$status = (( $status, " Mapped Drive" ) -Join ';').Trim(';')
		}
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Elevated privileges
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Shared with Me
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Guest accounts
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Authenticated proxies
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# OneNote notebooks 
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		# Handled with $isBlockedFileType
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# File upload size
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		If ( $fileMaxSize -LT $length ) {
			$isInvalid = $TRUE
			$totalInvalid++
			$isInvalidFileSize = $TRUE
			$status = (( $status, " Invalid file size '$length' greater than file max size '$fileMaxSize'" ) -Join ';').Trim(';')
		}
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# File name and path lengths
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		If ( $FullNameMaxLength -LT $fullName.Length ) {
			$isInvalid = $TRUE
			$totalInvalid++
			$isInvalidFullNameLength = $TRUE
			$status = (( $status, " Invalid file folder path length '$($fullName.Length)' greater than file folder path max length '$FullNameMaxLength'" ) -Join ';').Trim(';')
		}
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Thumbnails and previews
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Number of items that can be synced
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		If ( $FileMaxCount -LT $totalCountFile ) { 
			$isInvalid = $TRUE
			$totalInvalid++
			$isInvalidFileCount = $TRUE
			$status = (( $status, " Invalid file count '$totalCountFile' greater than max file count '$FileMaxCount'" ) -Join ';').Trim(';')			
		}
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Libraries with Information Rights Management enabled
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Differential sync
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Libraries with specific columns or metadata
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Windows specific restrictions and limitations
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# macOS specific restrictions and limitations
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
				
		# Don't propose a new path if same as original.  
		If ( $name -Eq $newName ) { $newName = '' }
		Write-Debug "`$newName:,$newName"
		Write-Debug "`$status:,$status"
		
		# Write result.
		Write-Output ( [PSCustomObject] @{ 
			BaseName = $baseName; 
			#Directory = $directory; 
			Extension = $extension; 
			FullName = $fullName; 
			FullNameLength = $fullName.Length;
			FullNameFolderDepth = $fullName.Split('\').Count - 2; # Don't count first and last components; PSDrive, Name
			Length = $length; 
			Name = $name; 
			NameLength = $name.Length; 
			IsContainer = $isContainer; 
			IsInvalid = $isInvalid; 
			IsInvalidCharacter = $isInvalidCharacter; 
			IsInvalidFolderName = $isInvalidFolderName; 
			IsInvalidFileName = $isInvalidFileName; 
			IsBlockedFileType = $isBlockedFileType; 
			IsNetwork = $isNetwork;
			IsMappedDrive = $isMappedDrive;
			IsInvalidFileSize = $isInvalidFileSize; 
			IsInvalidFullNameLength = $isInvalidFullNameLength; 
			TotalCount = $totalCount;
			TotalCountFile = $totalCountFile;
			TotalCountDirectory = $totalCountDirectory;
			TotalSize = $totalSize;
			Status = $status.Trim(' ');
			NewName = $newName; 
		} )
	} 
		
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	End {
		Write-Verbose "`$totalInvalid:,$totalInvalid"
		Write-Verbose "`$totalCount:,$totalCount"
		Write-Verbose "`$totalCountFile:,$totalCountFile"
		Write-Verbose "`$totalCountDirectory:,$totalCountDirectory"
		Write-Verbose "`$totalSize:,$totalSize"
	}

}
