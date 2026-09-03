# Local Publish - publica una URL local en Internet
# Uso:
#   .\Publish-Local.ps1
#   .\Publish-Local.ps1 http://localhost:3000
#   .\Publish-Local.ps1 3000
#   .\Publish-Local.ps1 -Url http://127.0.0.1:5173 -OpenBrowser

[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$Url,

  [switch]$OpenBrowser,
  [switch]$NoClipboard
)

$ErrorActionPreference = "Continue"
$ToolRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $ToolRoot "bin"
$Cloudflared = Join-Path $BinDir "cloudflared.exe"
$DownloadUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe"

function Write-Banner {
  Write-Host ""
  Write-Host "  ==============================================" -ForegroundColor Cyan
  Write-Host "   LOCAL PUBLISH  |  C:\CLAUDE tools" -ForegroundColor Cyan
  Write-Host "   Publica tu webapp local en Internet" -ForegroundColor Cyan
  Write-Host "  ==============================================" -ForegroundColor Cyan
  Write-Host ""
}

function Ensure-Cloudflared {
  if ((Test-Path $Cloudflared) -and ((Get-Item $Cloudflared).Length -gt 0)) {
    return
  }

  New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
  if (Test-Path $Cloudflared) {
    Remove-Item $Cloudflared -Force
  }

  Write-Host "Descargando cloudflared (primera vez)..." -ForegroundColor Yellow
  Write-Host "  $DownloadUrl" -ForegroundColor DarkGray

  try {
    $ErrorActionPreference = "Stop"
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $Cloudflared -UseBasicParsing
    $ErrorActionPreference = "Continue"
  }
  catch {
    $ErrorActionPreference = "Continue"
    Write-Host "ERROR: No se pudo descargar cloudflared." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Descarga manual: $DownloadUrl" -ForegroundColor Yellow
    Write-Host "Guardalo como:  $Cloudflared" -ForegroundColor Yellow
    exit 1
  }

  if (-not (Test-Path $Cloudflared) -or ((Get-Item $Cloudflared).Length -eq 0)) {
    Write-Host "ERROR: cloudflared.exe esta vacio o no existe." -ForegroundColor Red
    exit 1
  }

  Write-Host "OK cloudflared listo." -ForegroundColor Green
  Write-Host ""
}

function Normalize-Url([string]$inputUrl) {
  $raw = $inputUrl.Trim()
  if ($raw -match '^\d+$') { return "http://localhost:$raw" }
  if ($raw -notmatch '^https?://') { $raw = "http://$raw" }
  return $raw
}

function Test-LocalReachable([string]$targetUrl) {
  try {
    $null = Invoke-WebRequest -Uri $targetUrl -Method Head -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    return $true
  }
  catch {
    try {
      $null = Invoke-WebRequest -Uri $targetUrl -Method Get -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
      return $true
    }
    catch { return $false }
  }
}

function Get-LineText($obj) {
  if ($null -eq $obj) { return "" }
  if ($obj -is [System.Management.Automation.ErrorRecord]) {
    return [string]$obj.Exception.Message
  }
  return [string]$obj
}

Write-Banner
Ensure-Cloudflared

if (-not $Url) {
  Write-Host "Ejemplos:" -ForegroundColor DarkGray
  Write-Host "  http://localhost:3000     (ScrapIt / Next.js)"
  Write-Host "  http://localhost:5173     (Vite)"
  Write-Host "  3000                      (solo el puerto)"
  Write-Host ""
  $Url = Read-Host "URL o puerto local a publicar"
}

if ([string]::IsNullOrWhiteSpace($Url)) {
  Write-Host "No se indico ninguna URL. Saliendo." -ForegroundColor Red
  exit 1
}

$Target = Normalize-Url $Url
Write-Host "Objetivo local: $Target" -ForegroundColor White

if (-not (Test-LocalReachable $Target)) {
  Write-Host ""
  Write-Host "ADVERTENCIA: No se pudo conectar a $Target" -ForegroundColor Yellow
  Write-Host "Asegurate de que la webapp este corriendo (ej. npm run dev)." -ForegroundColor Yellow
  $continue = Read-Host "Continuar de todos modos? (s/N)"
  if ($continue -notin @("s", "S", "y", "Y", "si", "SI")) { exit 1 }
}

Write-Host ""
Write-Host "Creando tunel publico..." -ForegroundColor Cyan
Write-Host "Deja esta ventana ABIERTA mientras quieras compartir el enlace." -ForegroundColor Yellow
Write-Host "Ctrl+C para cerrar el tunel." -ForegroundColor Yellow
Write-Host ""

$announced = $false
$urlPattern = 'https://[a-zA-Z0-9-]+\.trycloudflare\.com'
$logFile = Join-Path $env:TEMP ("local-publish-" + [guid]::NewGuid().ToString("N") + ".log")

# Run via cmd so PowerShell does not treat cloudflared stderr INF lines as fatal errors
$cmdLine = "`"$Cloudflared`" tunnel --url `"$Target`" --no-autoupdate"

try {
  cmd.exe /c "$cmdLine 2>&1" | ForEach-Object {
    $line = Get-LineText $_
    if ([string]::IsNullOrWhiteSpace($line)) { return }

    Add-Content -Path $logFile -Value $line -ErrorAction SilentlyContinue

    if ((-not $announced) -and ($line -match $urlPattern)) {
      $publicUrl = $Matches[0]
      $announced = $true

      Write-Host ""
      Write-Host "  ==============================================" -ForegroundColor Green
      Write-Host "   PUBLICO - cualquiera puede ver tu app aqui:" -ForegroundColor Green
      Write-Host "   $publicUrl" -ForegroundColor White
      Write-Host "  ==============================================" -ForegroundColor Green
      Write-Host ""
      Write-Host "Local: $Target" -ForegroundColor DarkGray
      Write-Host ""

      if (-not $NoClipboard) {
        try {
          Set-Clipboard -Value $publicUrl
          Write-Host "URL copiada al portapapeles." -ForegroundColor Green
        }
        catch { }
      }

      if ($OpenBrowser) { Start-Process $publicUrl }
      Write-Host ""
    }
    elseif ($line -match 'failed to|error=|Unable to') {
      Write-Host $line -ForegroundColor DarkYellow
    }
  }
}
finally {
  Write-Host ""
  if (-not $announced) {
    Write-Host "No se detecto URL publica. Revisa el log:" -ForegroundColor Yellow
    Write-Host "  $logFile" -ForegroundColor DarkGray
    if (Test-Path $logFile) {
      Get-Content $logFile -Tail 30
    }
  }
  Write-Host "Tunel cerrado." -ForegroundColor Yellow
}
