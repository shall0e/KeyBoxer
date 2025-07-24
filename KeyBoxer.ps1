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

# simple setup of the shit
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
        # download the keybox, for some reason the header comes with like session cookies and stuff, but none of that is required.
        $response = (Invoke-WebRequest -Uri "https://tryigit.dev/keybox/download.php?id=random_strong" -ErrorAction Stop)
        $key = (Get-Hash($response.Content)).Substring(0,10)
        $hasCollectedThisSession = $true
        $filePath = (Join-Path $workingDir ("keybox_" + $key + '.xml'))

        echo ($response.Content).Substring(3) > $filePath
        log -Type Success -Color Green "Found keybox, stored in $filePath"
    }
    # catch if theres an error fetching, usually only error will be 429
    catch
    {
        $statusCode = $_.Exception.Response.StatusCode.value__

        if ($statusCode -eq 429)
        {
            if ($hasCollectedThisSession)
            {
                Log -Type Warning -Color DarkYellow "Too many requests, checking again in 15 minutes."
                Start-Sleep 910
            }
            else
            # when you are rate-limited and have to restart the scraping, it wont be exactly set to the 15 minute delay.
            # this is to get back on faster without extra unneeded delay, instead of waiting 15 minutes for an actual 5 minute wait.
            {
                Log -Type Warning -Color DarkYellow "Too many requests, out of sync, checking again in 3 minutes..."
                Log -Type Note -Color Magenta "This session hasn't found a keybox yet, once you find one, your delay will be 15 minutes."
                Start-Sleep 183
            }
        }
        else
        {
            Log -Type Error -Color Red "Request failed; $_"
            Start-Sleep 7
        }
    }
}
