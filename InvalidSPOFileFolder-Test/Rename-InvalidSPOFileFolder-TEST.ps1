Import-Module InvalidSPOFileFolder -Force

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Documents"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Documents"

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Documents Legacy2013"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Documents" -Recurse -Legacy2013 -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Documents-Legacy2013"

Out-Host -InputObject "$(Get-Date)`tC:\Users\Public\Documents"
Rename-InvalidSPOFileFolder -Path "C:\Users\Public\Documents" -Recurse -ExecutionSource '' -OutFileNameTag PublicDocuments

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Music"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Music" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`MusicInvalid"

Out-Host -InputObject "$(Get-Date)`tC:\Users\Public\Music"
Rename-InvalidSPOFileFolder -Path "C:\Users\Public\Music" -Recurse -ExecutionSource '' -OutFileNameTag PublicMusic

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Pictures"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Pictures"

Out-Host -InputObject "$(Get-Date)`tC:\Users\Public\Pictures"
Rename-InvalidSPOFileFolder -Path "C:\Users\Public\Pictures" -Recurse -ExecutionSource '' -OutFileNameTag PublicPictures

Out-Host -InputObject "$(Get-Date)`tC:\Users\$Env:USERNAME\Videos"
Rename-InvalidSPOFileFolder -Path "C:\Users\$Env:USERNAME\Videos" -Recurse -ExecutionSource '' -OutFileNameTag "$Env:USERNAME`Videos"

Out-Host -InputObject "$(Get-Date)`tC:\Users\Public\Videos"
Rename-InvalidSPOFileFolder -Path "C:\Users\Public\Videos" -Recurse -ExecutionSource '' -OutFileNameTag PublicVideos
