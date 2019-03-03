Import-Module InvalidSPOFileFolder -Force

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Documents"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`DocumentsInvalid" -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Documents" -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -AlertOnly -Legacy2013 -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`DocumentsInvalid-Legacy2013" -Debug

Write-Host "$(Get-Date)`tC:\Users\Public\Documents"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Documents" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicDocumentsInvalid -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Documents" -Recurse -ExecutionSource '' -OutFileNameTag PublicDocuments -Debug

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Music"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Music" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`MusicInvalid" -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Music" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`MusicInvalid" -Debug

Write-Host "$(Get-Date)`tC:\Users\Public\Music"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Music" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicMusicInvalid -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Music" -Recurse -ExecutionSource '' -OutFileNameTag PublicMusic -Debug

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Pictures"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Pictures" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`PicturesInvalid" -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Pictures" -Debug

Write-Host "$(Get-Date)`tC:\Users\Public\Pictures"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Pictures" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicPicturesInvalid -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag PublicPictures -Debug

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Videos"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Videos" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`VideosInvalid" -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Videos" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Videos" -Debug

Write-Host "$(Get-Date)`tC:\Users\Public\Videos"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Videos" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicVideosInvalid -Debug
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Videos" -Recurse -ExecutionSource '' -OutFileNameTag PublicVideos -Debug
