Import-Module InvalidSPOFileFolder -Force

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Documents"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Documents"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`DocumentsInvalid"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -AlertOnly -Legacy2013 -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`DocumentsInvalid-Legacy2013"

Out-Host -InputObject "$(Get-Date)`tC:\Users\Public\Documents"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Documents" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicDocumentsInvalid
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Documents" -Recurse -ExecutionSource '' -OutFileNameTag PublicDocuments

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Music"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Music" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`MusicInvalid"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Music" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`MusicInvalid"

Out-Host -InputObject "$(Get-Date)`tC:\Users\Public\Music"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Music" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicMusicInvalid
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Music" -Recurse -ExecutionSource '' -OutFileNameTag PublicMusic

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Pictures"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Pictures" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`PicturesInvalid"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Pictures"

Out-Host -InputObject "$(Get-Date)`tC:\Users\Public\Pictures"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Pictures" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicPicturesInvalid
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag PublicPictures

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Videos"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Videos" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`VideosInvalid"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Videos" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Videos"

Out-Host -InputObject "$(Get-Date)`tC:\Users\Public\Videos"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Videos" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicVideosInvalid
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Videos" -Recurse -ExecutionSource '' -OutFileNameTag PublicVideos
