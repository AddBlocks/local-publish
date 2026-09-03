# Local Publish shortcut helper
# Run once: powershell -ExecutionPolicy Bypass -File C:\CLAUDE\tools\local-publish\Create-DesktopShortcut.ps1

$Wsh = New-Object -ComObject WScript.Shell
$Shortcut = $Wsh.CreateShortcut("$env:USERPROFILE\Desktop\Local Publish.lnk")
$Shortcut.TargetPath = "C:\CLAUDE\tools\local-publish\publish-local.bat"
$Shortcut.WorkingDirectory = "C:\CLAUDE\tools\local-publish"
$Shortcut.Description = "Publicar webapp local en Internet"
$Shortcut.Save()
Write-Host "Acceso directo creado en el Escritorio: Local Publish.lnk" -ForegroundColor Green
