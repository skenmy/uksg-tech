# UKSG Tech Initialization Script
# Written by Paul Williams <paul@skenmy.com>

# This script automates the download of the UKSG Tech
# Installer & Updater Script

## Function Definitions
function Set-Environment {
    Write-Host "Refreshing Environment"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
function Write-Header {

    param (
        $Text
    )

    Write-Host ""
    Write-Host "################################################################################"
    Write-Host "##" $Text
    Write-Host "################################################################################"
    Write-Host ""
}

function Exit-After-Keypress {
    Write-Host -NoNewline "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyUp');
    Write-Host ""
    exit
}

function Enter-After-Keypress {
    Write-Host -NoNewline "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyUp');
    Write-Host ""
}

function Test-Exit-Code {
    if ($LASTEXITCODE -ne 0) {
        Write-Host -ForegroundColor Red "Something went wrong..."
        Write-Host "Please check the output above to see what went wrong. This script will now exit."
        Exit-After-Keypress
    }
}

function Invoke-Command-Surround-Output {
    Write-Host "|" $args "|"
    Write-Host "--------------------------------------------------------------------------------"
    Invoke-Expression "$args"
    Write-Host "--------------------------------------------------------------------------------"
    Test-Exit-Code
}

function Invoke-Command-Surround-Output-Ignore-Exit {
    Write-Host "|" $args "| (ignoring exit code)"
    Write-Host "--------------------------------------------------------------------------------"
    Invoke-Expression "$args"
    Write-Host "--------------------------------------------------------------------------------"
}

## Execution
if (!
    (New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
) {
    Write-Host -ForegroundColor Red -BackgroundColor Black "This script must be run in Administrator Powershell"
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "Right click the script -> Run as administrator"
    Write-Host "Run RegistryTweaks.reg to add the right-click command if it doesn't appear."
    Exit-After-Keypress
}

Write-Header "UKSG Tech - PC Initialization Script"
Write-Host -ForegroundColor Black -BackgroundColor Red "Do not execute this script unless this is a brand new, unconfigured PC!"
Enter-After-Keypress
Write-Host "Please select the directory to use!"
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.FolderBrowserDialog
$null = $browser.ShowDialog()
$path = $browser.SelectedPath
Write-Host "Using "$path
Enter-After-Keypress

# Set System Settings
Write-Header "System Settings"

Write-Host "Setting ExecutionPolicy to Bypass..."
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
Write-Host -ForegroundColor Green "Success"

# Install / Upgrade Chocolatey
Write-Header "Package Manager"
Write-Host "Installing / Updating Chocolatey..."
Set-Environment
if ( -not (Get-Command choco -errorAction SilentlyContinue)) {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Set-Environment
    if ( -not (Get-Command choco -errorAction SilentlyContinue)) {
        Write-Host "Chocolatey was just installed - but we can't access it unless we restart the script!"
        Write-Host -ForegroundColor Yellow "You must restart this script to continue!"
        Exit-After-Keypress
    }
}

Invoke-Command-Surround-Output choco upgrade chocolatey -y

# Update these scripts & config files
Write-Header "Update Scripts"
# Install / Upgrade Git
Write-Host "Installing / Updating Git..."
Invoke-Command-Surround-Output choco upgrade git -y
Set-Environment

Write-Host "Setting Working Directory..."
Set-Location -Path $path
Write-Host -ForegroundColor Green "Success"

Write-Host "Downloading Scripts & Configs..."
Invoke-Command-Surround-Output git clone https://github.com/skenmy/uksg-tech.git .
Write-Host -ForegroundColor Green "Success"

Write-Host "Set Directory Safety"
Invoke-Command-Surround-Output git config --global --add safe.directory $path
Write-Host -ForegroundColor Green "Success"

Write-Header "All Done!"
Write-Host -ForegroundColor Green "You can now use the scripts in "$path" to setup this computer!"
Exit-After-Keypress
