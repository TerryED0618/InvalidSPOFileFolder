Import-Module InvalidSPOFileFolder -Force

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Documents"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Documents"

Write-Host "$(Get-Date)`tC:\Users\Public\Documents"
Rename-InvalidSPOFileFolder -Path "C:\Users\Public\Documents" -Recurse -ExecutionSource '' -OutFileNameTag PublicDocuments

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Music"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Music" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`MusicInvalid"

Write-Host "$(Get-Date)`tC:\Users\Public\Music"
Rename-InvalidSPOFileFolder -Path "C:\Users\Public\Music" -Recurse -ExecutionSource '' -OutFileNameTag PublicMusic

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Pictures"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Pictures"

Write-Host "$(Get-Date)`tC:\Users\Public\Pictures"
Rename-InvalidSPOFileFolder -Path "C:\Users\Public\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag PublicPictures

Write-Host "$(Get-Date)`tC:\Users\$Env:USERNAME\Videos"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Videos" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Videos"

Write-Host "$(Get-Date)`tC:\Users\Public\Videos"
Rename-InvalidSPOFileFolder -Path "C:\Users\Public\Videos" -Recurse -ExecutionSource '' -OutFileNameTag PublicVideos
