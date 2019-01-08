# InvalidSPOFileFolder
---
## Description
  Test if a FileSystem item is invalid for synchronization with OneDrive, OneDrive for Business, and SharePoint.

---
## Test-InvalidSPOFileFolder
### SYNOPSIS
		Test if a FileSystem item is invalid for synchronization with OneDrive, OneDrive for Business, and SharePoint.

### DESCRIPTION
		Provided a FileSystem's DirectoryInfo or FileInfo item (from Get-ChildItem or Get-Item) determine if the item's metadata is invalid for synchronition with OneDrive, OneDrive for Business, and SharePoint.  

### PARAMETER ItemInfo [DirectoryInfo] or [FileInfo]
		A FileSystem item either of type DirectoryInfo or FileInfo.  

### PARAMETER SpecialCharactersStateInFileFolderNamesAllowed SwitchParameter
		When enabled test for invalid characters allowed by SharePoint Server 2016 and newer.  
		When disabled test for invalid characters allowed by SharePoint Server 2013 and older.  
		Parameter alias is Legacy2013.  
		
### EXAMPLE
		Get-ChildItem -Path C:\Users\<UserName>\Documents -Recurse |
			Test-InvalidSPOFileFolder | 
			Export-CSV -Path '.\Test-InvalidSPOFileFolder.csv'

### NOTE
		Author: Terry E Dow
		Creation Date: 2018-12-23
		
		Reference:
			Invalid file names and file types in OneDrive, OneDrive for Business, and SharePoint
			https://support.office.com/en-us/article/invalid-file-names-and-file-types-in-onedrive-onedrive-for-business-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa?ui=en-US&rs=en-US&ad=US#invalidcharacters
---
## Test-InvalidSPOFileFolderToCSV
### SYNOPSIS
			Provided with a Get-ChildItem FileSystem path and parameters, test if the folder and file items are invalid for synchronization with OneDrive, OneDrive for Business, and SharePoint.

### DESCRIPTION
			The Get-ChildItem cmdlet gets the items in one or more specified locations. If the item is a container, it gets the items inside the container, known as child items. You can use the Recurse parameter to get items in all child containers.

			A location can be a file system location, such as a directory, or a location exposed by a different Windows PowerShell provider, such as a registry hive or a certificate store.
			In a file system drive, the Get-ChildItem cmdlet gets the directories, subdirectories, and files. In a file system directory, it gets subdirectories and files. 

			By default, Get-ChildItem gets non-hidden items, but you can use the Directory, File, Hidden, ReadOnly, and System parameters to get only items with these attributes. To create a complex attribute search, use the Attributes parameter. If you use these parameters, Get-ChildItem gets only the items that meet all search conditions, as though the parameters were connected by an AND operator. 

			Note: This custom cmdlet help file explains how the Get-ChildItem cmdlet works in a file system drive. For information about the Get-ChildItem cmdlet in all drives, type "Get-Help Get-ChildItem -Path $null" or see Get-ChildItem at http://go.microsoft.com/fwlink/?LinkID=113308.

###	OUTPUTS
			One output file is generated by default in a subfolder called '.\Reports\'.  The output file name is in the format of: <date/time/timezone stamp>-<msExchOrganizationContainer>-<ScriptName>.CSV.
			If parameter -Debug or -Verbose is specified, then a second file, a PowerShell transcript (*.TXT), is created with the same name and in the same location.

			The input file is read, two additional columns are added 'IsCompliant' and 'Status', and then written to the output file.  IsCompliant has a TRUE or FALSE value.  Status is either empty, or has a combined list of all non-compliance.

### PARAMETER SpecialCharactersStateInFileFolderNamesAllowed SwitchParameter
			When enabled test for invalid characters allowed by SharePoint Server 2016 and newer.  
			When disabled test for invalid characters allowed by SharePoint Server 2013 and older.  
			Parameter alias is Legacy2013.  
			
###	PARAMETER Attributes FileAttributes
			Gets files and folders with the specified attributes. This parameter supports all attributes and lets you specify complex combinations of attributes.

			For example, to get non-system files (not directories) that are encrypted or compressed, type:
				Get-ChildItem -Attributes !Directory+!System+Encrypted, !Directory+!System+Compressed

			To find files and folders with commonly used attributes, you can use the Attributes parameter, or the Directory, File, Hidden, ReadOnly, and System switch parameters.

			The Attributes parameter supports the following attributes: Archive, Compressed, Device, Directory, Encrypted, Hidden, Normal, NotContentIndexed, Offline, ReadOnly, ReparsePoint, SparseFile, System, and Temporary. For a description of these attributes, see the FileAttributes enumeration at http://go.microsoft.com/fwlink/?LinkId=201508.

			Use the following operators to combine attributes.
				!	NOT
				+	AND
				,	OR
			No spaces are permitted between an operator and its attribute. However, spaces are permitted before commas.

			You can use the following abbreviations for commonly used attributes:
				D	Directory
				H	Hidden
				R	Read-only
				S	System

###	PARAMETER Directory SwitchParameter
			Gets directories (folders).  

			To get only directories, use the Directory parameter and omit the File parameter. To exclude directories, use the File parameter and omit the Directory parameter, or use the Attributes parameter. 

			To get directories, use the Directory parameter, its "ad" alias, or the Directory attribute of the Attributes parameter.

### PARAMETER File SwitchParameter
			Gets files. 

			To get only files, use the File parameter and omit the Directory parameter. To exclude files, use the Directory parameter and omit the File parameter, or use the Attributes parameter.

			To get files, use the File parameter, its "af" alias, or the File value of the Attributes parameter.

### PARAMETER Hidden SwitchParameter
			Gets only hidden files and directories (folders).  By default, Get-ChildItem gets only non-hidden items, but you can use the Force parameter to include hidden items in the results.

		To get only hidden items, use the Hidden parameter, its "h" or "ah" aliases, or the Hidden value of the Attributes parameter. To exclude hidden items, omit the Hidden parameter or use the Attributes parameter.

### PARAMETER ReadOnly SwitchParameter
			Gets only read-only files and directories (folders).  

		To get only read-only items, use the ReadOnly parameter, its "ar" alias, or the ReadOnly value of the Attributes parameter. To exclude read-only items, use the Attributes parameter.

### PARAMETER System SwitchParameter
			Gets only system files and directories (folders).

			To get only system files and folders, use the System parameter, its "as" alias, or the System value of the Attributes parameter. To exclude system files and folders, use the Attributes parameter.

###	PARAMETER Force SwitchParameter
			Gets hidden files and folders. By default, hidden files and folder are excluded. You can also get hidden files and folders by using the Hidden parameter or the Hidden value of the Attributes parameter.

### PARAMETER UseTransaction SwitchParameter
			Includes the command in the active transaction. This parameter is valid only when a transaction is in progress. For more information, see about_Transactions.

### PARAMETER Depth UInt32
			{{Fill Depth Description}}

### PARAMETER Exclude String[]
			Specifies, as a string array, an item or items that this cmdlet excludes in the operation. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as *.txt. Wildcards are permitted.

### PARAMETER Filter String
			Specifies a filter in the provider's format or language. The value of this parameter qualifies the Path parameter. The syntax of the filter, including the use of wildcards, depends on the provider. Filters are more efficient than other parameters, because the provider applies them when retrieving the objects, rather than having Windows PowerShell filter the objects after they are retrieved.

### PARAMETER Include String[]
			Specifies, as a string array, an item or items that this cmdlet includes in the operation. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as *.txt. Wildcards are permitted.

			The Include parameter is effective only when the command includes the Recurse parameter or the path leads to the contents of a directory, such as C:\Windows\*, where the wildcard character specifies the contents of the C:\Windows directory.

### PARAMETER LiteralPath String[]
			Specifies, as a string arrya, a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters as escape sequences.

### PARAMETER Name SwitchParameter
			Indicates that this cmdlet gets only the names of the items in the locations. If you pipe the output of this command to another command, only the item names are sent.

### PARAMETER Path String[]
			Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory (.).

### PARAMETER Recurse SwitchParameter
			Indicates that this cmdlet gets the items in the specified locations and in all child items of the locations.

			In Windows PowerShell 2.0 and earlier versions of Windows PowerShell, the Recurse parameter works only when the value of the Path parameter is a container that has child items, such as C:\Windows or C:\Windows\ , and not when it is an item does not have child items, such as C:\Windows\ .exe.

### EXAMPLE
			Description
			-----------
			This command gets the files and subdirectories in the current directory. If the current directory does not have child items, the command does not return any results.
			Get-ChildItem

### EXAMPLE
			Description
			-----------
			This command gets system files in the current directory and its subdirectories.
			Get-Childitem -System -File -Recurse

### EXAMPLE
			Description
			-----------
			These command get all files, including hidden files, in the current directory, but exclude subdirectories. The second command uses aliases and abbreviations, but has the same effect as the first.
			Get-ChildItem -Attributes !Directory,!Directory+Hidden

			C:\PS> dir -att !d,!d+h

### EXAMPLE
			Description
			-----------
			This command gets the subdirectories in the current directory. It uses the "dir" alias of the Get-ChildItem cmdlet and the "ad" alias of the Directory parameter.
			dir -ad

### EXAMPLE
			Description
			-----------
			This command gets read-write files in the C:\ps-test directory.
			Get-ChildItem -File -Attributes !ReadOnly -path C:\ps-test

### EXAMPLE
			Description
			-----------
			This command gets all of the .txt files in the current directory and its subdirectories. 

			The dot (.) represents the current directory. The Include parameter specifies the file name extension. The Recurse parameter directs Windows PowerShell to search for objects recursively, and it indicates that the subject of the command is the specified directory and its contents. The Force parameter adds hidden files to the display.
			get-childitem . -include *.txt -recurse -force

### EXAMPLE
			Description
			-----------
			This command gets the .txt files in the Logs subdirectory, except for those whose names start with the letter A. It uses the wildcard character (*) to indicate the contents of the Logs subdirectory, not the directory container. Because the command does not include the Recurse parameter, Get-ChildItem does not include the contents of the current directory automatically; you need to specify it.
			get-childitem c:\windows\logs\* -include *.txt -exclude A*

### EXAMPLE
			Description
			-----------
			This command retrieves only the names of items in the current directory.
			get-childitem -name			

### NOTE
			Author: Terry E Dow
			Creation Date: 2018-12-23