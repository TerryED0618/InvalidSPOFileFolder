Import-Module InvalidSPOFileFolder -Force

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Documents"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`DocumentsInvalid" -Verbose
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Documents" -Verbose

Write-Host "$(Get-Date)`tC:\Users\Public\Documents"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Documents" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicDocumentsInvalid -Verbose
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Documents" -Recurse -ExecutionSource '' -OutFileNameTag PublicDocuments -Verbose

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Music"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Music" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`MusicInvalid" -Verbose
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Music" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`MusicInvalid" -Verbose

Write-Host "$(Get-Date)`tC:\Users\Public\Music"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Music" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicMusicInvalid -Verbose
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Music" -Recurse -ExecutionSource '' -OutFileNameTag PublicMusic -Verbose

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Pictures"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Pictures" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`PicturesInvalid" -Verbose
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Pictures" -Verbose

Write-Host "$(Get-Date)`tC:\Users\Public\Pictures"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Pictures" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicPicturesInvalid -Verbose
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag PublicPictures -Verbose

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Videos"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Videos" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`VideosInvalid" -Verbose
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\$Env:USERNAME\Videos" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Videos" -Verbose

Write-Host "$(Get-Date)`tC:\Users\Public\Videos"
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Videos" -Recurse -AlertOnly -ExecutionSource '' -OutFileNameTag PublicVideosInvalid -Verbose
Test-InvalidSPOFileFolderToCSV -Path "C:\Users\Public\Videos" -Recurse -ExecutionSource '' -OutFileNameTag PublicVideos -Verbose
