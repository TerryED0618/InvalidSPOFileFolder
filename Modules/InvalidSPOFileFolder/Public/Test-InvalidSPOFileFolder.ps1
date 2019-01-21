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
		Get-ChildItem -Path "C:\Users\$Env:USERNAME\Documents" -Recurse |
			Test-InvalidSPOFileFolder | 
			Export-CSV -Path '.\Test-InvalidSPOFileFolder.csv'
	
	.NOTE
		Author: Terry E Dow
		Creation Date: 2018-12-23
		Last Updated: 2019-01-13

		Reference:
		# Invalid file names and file types in OneDrive, OneDrive for Business, and SharePoint
		# 	https://support.office.com/en-us/article/invalid-file-names-and-file-types-in-onedrive-onedrive-for-business-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa?ui=en-US&rs=en-US&ad=US#invalidcharacters
		# “Sorry, OneDrive can’t add your folder right now.”
		# 	https://blogs.technet.microsoft.com/odfb/2017/02/07/sorry-onedrive-cant-add-your-folder-right-now/
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

		# Collect script execution metrics.
		$scriptStartTime = Get-Date
		Write-Verbose "`$scriptStartTime:,$($scriptStartTime.ToString('s'))"

		# Initialize all item metrics.
		$totalCount = 0
		$totalCountDirectory = 0
		$totalCountFile = 0
		$totalInvalid = 0
		$totalSize = 0
		$maxFullNameLength = 0

		# Define restrictions and limitations.
		If ( $SpecialCharactersStateInFileFolderNamesAllowed ) {
			# RegEx Esc Char . $ ^ { [ ( | ) * + ? \
			
			# " * : < > ? / \ |
			$invalidCharactersPattern = [RegEx] '["|\*|:|<|>|\?|/|\\|\|]'
		} Else {
			# ~ " # % & * : < > ? / \ { | }
			$invalidCharactersPattern = [RegEx] '[~|"|#|%|&|\*|:|<|>|\?|/|\\|{|\||}]'
		}
		
		$seperator = [System.IO.Path]::DirectorySeparatorChar
		$seperatorEscaped = $seperator.ToString() * 2
		
		# 2.2.57 UNC https://msdn.microsoft.com/en-us/library/gg465305.aspx
		# "\\" host-name "\" share-name  [ "\" object-name ]
		$UNCPathPrefixPattern = [RegEx] '$seperatorEscaped$seperatorEscaped[^$seperatorEscaped]{1,16}' # \\host-name\share-name\volume https://docs.microsoft.com/en-us/dotnet/standard/io/file-path-formats NetBIOS Name https://msdn.microsoft.com/en-us/library/dd891456.aspx
		$FileSystemPrefixPattern = [RegEx] '[A-Z]:' # volume-name: https://docs.microsoft.com/en-us/dotnet/standard/io/file-path-formats
		$InvalidFileName = [RegEx] '^(:?\.lock|CON|PRN|AUX|NUL|COM1|COM2|COM3|COM4|COM5|COM6|COM7|COM8|COM9|LPT1|LPT2|LPT3|LPT4|LPT5|LPT6|LPT7|LPT8|LPT9|_vti_|desktop\.ini)$' #@( '.lock', 'CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9', '_vti_', 'desktop.ini' ) -Contains
		$InvalidFileNameStartsWith = [RegEx] '^[~|\$]'
		$InvalidFolderName = [RegEx] '^(:?_vti_|forms)$' # @( '_vti_', 'forms' ) -Contains
		$BlockedFileType = [RegEx] '^(?:\.pst|\.one$)' # @( '.pst', '.one' ) -Contains
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
		Write-Verbose "`$fullName:,$fullName"
		Try { $size = $ItemInfo.Length } Catch { $size = 0 }
		Write-Debug "`$size:,$size"
		$name = $ItemInfo.Name
		Write-Debug "`$name:,$name"
		$isContainer = $ItemInfo.PSIsContainer
		Write-Debug "`$isContainer:,$isContainer"
		#$fileName = $ItemInfo.VersionInfo.FileName
		#Write-Debug "`$fileName:,fileName"
		
		# Collect all item metrics.
		$totalCount++
		$totalSize += $size
		
		# Initialize this item's metrics. 		
		$isInvalid = $FALSE
		$isInvalidCharacter = $FALSE
		$isInvalidFolderName = $FALSE
		$isInvalidFileCount = $FALSE
		$isInvalidFileName = $FALSE
		$isInvalidFileSize = $FALSE
		$isBlockedFileType = $FALSE
		$isInvalidFullNameLength = $FALSE
		$isMappedDrive = $FALSE
		$isNetwork = $FALSE
		$status = ''
		$newName = $Name
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Restrictions: ---2----+----3----+----4----+----5----+----6----+----7----+----8
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
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
			If ( $newName -Match $invalidFolderName ) { 
				$isInvalid = $TRUE
				$totalInvalid++
				$isInvalidFolderName = $TRUE
				$status = (( $status, " Invalid FolderName '$newName'" ) -Join ';').Trim(';')
				
				$newName = "-$newName-" 
			}		
		} Else {
			$totalCountFile++
			If ( $newName -Match $invalidFileName -Or $newName -Match $invalidFileNameStartsWith ) {
				$isInvalid = $TRUE
				$totalInvalid++
				$isInvalidFileName = $TRUE
				$status = (( $status, " Invalid FileName '$newName'" ) -Join ';').Trim(';')
				
				$newName = "-$newName-" 
			}
		}

		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Invalid or blocked file types
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

		If ( $extension -Match $blockedFileType ) { 
			$isInvalid = $TRUE
			$totalInvalid++
			$isBlockedFileType = $TRUE
			$status = (( $status, " Blocked FileType" ) -Join ';').Trim(';')
		}
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# Network or mapped drives
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

		# If UNC path prefix
		If ( $fullName -Match $UNCPathPrefixPattern ) { 
			$isInvalid = $TRUE
			$totalInvalid++
			$isNetwork = $TRUE
			$status = (( $status, " Network" ) -Join ';').Trim(';')
		}
		
		# If FileSystem device type is Network
		#Write-Debug ( Get-CimInstance Win32_LogicalDisk -Filter "DeviceId='$($fullName[0]):'" ).DriveType
		# <<<< TODO cache results
		IF ( $fullName -CMatch $FileSystemPrefixPattern -And (( Get-CimInstance Win32_LogicalDisk -Filter "DeviceId='$($fullName[0]):'" -Verbose:$FALSE -Debug:$FALSE ).DriveType -EQ 4) ) { # DriveType Network = 4
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
		# Limitations: ----2----+----3----+----4----+----5----+----6----+----7----+----8
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		# File upload size
		#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
		
		If ( $fileMaxSize -LT $size ) {
			$isInvalid = $TRUE
			$totalInvalid++
			$isInvalidFileSize = $TRUE
			$status = (( $status, " Invalid file size '$size' greater than file max size '$fileMaxSize'" ) -Join ';').Trim(';')
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
		
		# Thumbs.db
		# ehthumbs.db
		
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
			FullNameFolderDepth = $fullName.Split($seperator).Count - 2; # Don't count first and last components; <PSDrive>\..\<Name>
			Size = $size; 
			Name = $name; 
			NameLength = $name.Length; 
			IsContainer = $isContainer; 
			IsInvalid = $isInvalid; 
			IsBlockedFileType = $isBlockedFileType; 
			IsInvalidCharacter = $isInvalidCharacter; 
			IsInvalidFileCount = $isInvalidFileCount;
			IsInvalidFileName = $isInvalidFileName; 
			IsInvalidFileSize = $isInvalidFileSize; 
			IsInvalidFolderName = $isInvalidFolderName; 
			IsInvalidFullNameLength = $isInvalidFullNameLength; 
			IsMappedDrive = $isMappedDrive;
			IsNetwork = $isNetwork;
			Status = $status.Trim(' ');
			NewName = $newName; 
			TotalCount = $totalCount;
			TotalCountDirectory = $totalCountDirectory;
			TotalCountFile = $totalCountFile;
			TotalInvalid = $totalInvalid;
			TotalSize = $totalSize;
		} )
	} 
		
	#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
	End {
		Write-Verbose "`$totalCount:,$totalCount"
		Write-Verbose "`$totalCountFile:,$totalCountFile"
		Write-Verbose "`$totalCountDirectory:,$totalCountDirectory"
		Write-Verbose "`$totalInvalid:,$totalInvalid"
		Write-Verbose "`$totalSize:,$totalSize"
		
		$scriptEndTime = Get-Date
		Write-Verbose "`$scriptEndTime:,$($scriptEndTime.ToString('s'))"
		$scriptElapsedTime =  $scriptEndTime - $scriptStartTime
		Write-Verbose "`$scriptElapsedTime:,$scriptElapsedTime"
	}

}
