# Sanitize or desanitize script files so they are safe to email.  

---
## Desanitize - remove *.TXT extension for any file name with a nested extension ending with '.TXT'
### For example rename BATCH.CMD.TXT to BATCH.CMD or SCRIPT.PS1.TXT to SCRIPT.PS1
Get-ChildItem -Path *.*.TXT -File -Recurse | ForEach-Object { Rename-Item -Path $PSItem.VersionInfo.FileName -NewName ( $PSItem.VersionInfo.FileName -Replace '\.TXT$', '' ) -PassThru }

---
## Sanitize - add *.TXT extention for all script files ( *.BAT, *.CMD, *.PS1, *.PSD1, *.PSM1 )
### For example rename BATCH.CMD to BATCH.CMD.TXT or SCRIPT.PS1 to SCRIPT.PS1.TXT
Get-ChildItem *.BAT,*.CMD,*.PS1,*.PSD1,*.PSM1 -Exclude *.TXT -File -Recurse | ForEach-Object { Rename-Item -Path $PSItem.VersionInfo.FileName -NewName "$($PSItem.VersionInfo.FileName).TXT" -PassThru }

---
## Remove remote file identifier.
Get-ChildItem *.BAT,*.CMD,*.PS1,*.PSD1,*.PSM1 -Recurse | ForEach-Object { If ( $stream = Get-Item $PSItem.VersionInfo.FileName -Stream * | Where-Object { $PSItem.Stream -Contains 'Zone.Identifier' } ) { Unblock-File -LiteralPath $stream.FileName -Verbose } }