function Log
{
    param
    (
        [string]$Message,
        [string]$Type = "Log",
        [string]$Color = "DarkGray",
        [bool]$timestamp = $true
    )
    Write-Host "" -NoNewLine -ForegroundColor Gray
    if ($timestamp)
    {
        Write-Host "(" -NoNewline -ForegroundColor Gray
        Write-Host (Get-Date).ToString("hh:mm:ss") -NoNewline -ForegroundColor DarkGray
        Write-Host ") " -NoNewline -ForegroundColor Gray
    }
    Write-Host "[" -NoNewline -ForegroundColor Gray
    Write-Host "$Type" -NoNewline -ForegroundColor $Color
    Write-Host "] " -NoNewline -ForegroundColor Gray
    Write-Host $Message
}

function Get-Hash
{
    param
    (
        [string]$Text,
        [string]$Algorithm = "MD5"
    )

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hasher = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm)
    $hashBytes = $hasher.ComputeHash($bytes)
    return ($hashBytes | ForEach-Object { $_.ToString("x2") }) -join ""
}

function betterPause
{
    param
    (
        [string]$Message,
        [string]$Color="Red"
    )
    if ($Message -ne "")
    {
        Write-Host $Message -ForegroundColor $Color
    }
    Write-Host ' '
    Write-Host -ForegroundColor Magenta "(Press Enter to go continue)" -NoNewline
    $null = Read-Host
}

function Get-PublicIP {
    try {
        $ip = Invoke-RestMethod -Uri 'https://api.ipify.org'
        return $ip
    } catch {
        return "Error"
    }
}

function Restart-WAN {
    $plinkPath = ".\plink.exe"
    $routerIP = "192.168.1.1"
    $user = ""
    $pass = ""

    $ipBefore = Get-PublicIP
    Log -Type Info -Color Cyan "IP pública antes del reinicio: $ipBefore"

    $cmd = "$plinkPath -ssh $user@$routerIP -pw $pass 'ifup wan'"
    Log -Type Info -Color Cyan "Reiniciando la interfaz WAN vía SSH ($routerIP)..."
    try {
        $output = Invoke-Expression $cmd
        Log -Type Info -Color Cyan "Comando ifup wan ejecutado, esperando 15 segundos..."
        Start-Sleep 5
    } catch {
        Log -Type Error -Color Red "Error ejecutando ifup wan por SSH: $_"
    }

    # Espera a que vuelva la conexión y obtén la nueva IP pública
    $ipAfter = "Error"
    $maxTries = 10
    for ($i=0; $i -lt $maxTries; $i++) {
        $ipAfter = Get-PublicIP
        if ($ipAfter -ne "Error" -and $ipAfter -ne $ipBefore) {
            break
        }
        Start-Sleep 5
    }
    Log -Type Info -Color Cyan "IP pública después del reinicio: $ipAfter"
    if ($ipBefore -eq $ipAfter) {
        Log -Type Warning -Color Yellow "¡La IP pública no ha cambiado! Puede que sigas bloqueado."
    } else {
        Log -Type Success -Color Green "¡La IP pública ha cambiado correctamente!"
    }
}

cls
$host.UI.RawUI.WindowTitle = "KeyBoxer - v1.0 - @shall0e"

# introduction to what this is
echo 'Hello! This is a tool meant to siphon and scrape Strong keyboxes from "tryigit.dev"'
echo 'This service claims that your keyboxes are in safe hands, but also invites VIP access,'
echo 'and provides a fake keybox checker. They claim that every thing is checked in your'
echo 'browser while it actually uploads and "steals" your own keyboxes.'
echo ''
echo 'Bringing power to the people, this will scrape their "random strong keybox" service'
echo 'to obtain all of their stored keys.'
echo ''
echo 'Made by @shall0e'

Write-Host ("-" * 65) -ForegroundColor DarkGray

# ive been using this function for like 2 years now
betterPause -Message "Are you sure you want to start this program?" -Color White

start-sleep 1
cls

# simple setup
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = 'SilentlyContinue'
$hasCollectedThisSession = $false
$workingDir = (Join-Path (pwd) 'keyboxes')
start-sleep 1

if (-not (Test-Path $workingDir))
{
    New-Item -ItemType Directory -Path $workingDir | Out-Null
}

Log "Starting keybox scraper..."

# general loop
while ($true)
{
    Start-Sleep 1
    try
    {
        # download the keybox
        $response = (Invoke-WebRequest -Uri "https://tryigit.dev/keybox/download.php?id=random_strong" -ErrorAction Stop)
        $key = (Get-Hash($response.Content)).Substring(0,10)
        $hasCollectedThisSession = $true
        $filePath = (Join-Path $workingDir ("keybox_" + $key + '.xml'))

        echo ($response.Content).Substring(3) > $filePath
        log -Type Success -Color Green "Found keybox, stored in $filePath"
    }
    catch
    {
        $statusCode = $_.Exception.Response.StatusCode.value__

        if ($statusCode -eq 429)
        {
            Log -Type Warning -Color Yellow "Too many requests. Reiniciando WAN en el router para obtener nueva IP..."
            Restart-WAN
            Log -Type Info -Color Magenta "Intentando scraping de nuevo tras reinicio WAN..."
        }
        else
        {
            Log -Type Error -Color Red "Request failed; $_"
            Start-Sleep 7
        }
    }
}
