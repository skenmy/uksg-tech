# UKSG Tech Installer / Upgrader Script
# Written by Paul Williams <paul@skenmy.com>

# This script automates the installation of a number of
# software packages that the Tech PC needs. It is designed to
# keep things up to date in a repeatable and predictable way.
# It will also guide you through any manual steps required
# to get the PC ready for an event.

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
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    Write-Host ""
    exit
}

function Enter-After-Keypress {
    Write-Host -NoNewline "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
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

Write-Header "UKSG Tech Installer / Upgrader"
Write-Host "Running in" $PSScriptRoot
Write-Host "NodeCG will be set up & configured in" $PSScriptRoot"\nodecg"
Write-Host -ForegroundColor Yellow "This script may need to be run multiple times - it will tell you if this is the case."
Write-Host -ForegroundColor Red "Do not execute this script unless you have been told to run it, or you know what it does!"
Write-Host -ForegroundColor Black -BackgroundColor Red "Do not execute this script if you are currently running a marathon - bad things will happen!"
Enter-After-Keypress

# Set System Settings
Write-Header "System Settings"
Write-Host "Setting Working Directory..."
Set-Location -Path $PSScriptRoot
Write-Host -ForegroundColor Green "Success"

Write-Host "Setting ExecutionPolicy to Bypass..."
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
Write-Host -ForegroundColor Green "Success"

Write-Host "Setting System Timezone..."
Set-TimeZone -Id "GMT Standard Time"
Write-Host -ForegroundColor Green "Success"

Write-Host "Setting System Locale & Input Settings..."
Set-WinSystemLocale en-GB
Set-WinDefaultInputMethodOverride -InputTip "0809:00000809" # en-GB Keyboard Layout
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

Write-Host "Checking for script updates..."
Invoke-Command-Surround-Output git fetch

$gitBehind = cmd.exe /c 'git status | find /i "Your branch is behind"'
if ($gitBehind) {
    Write-Host -ForegroundColor Red "Updates found... downloading..."
    Invoke-Command-Surround-Output git pull
    Write-Host -ForegroundColor Yellow "You must restart this script to run the updated version!"
    Exit-After-Keypress
}

# Install / Upgrade Packages
Write-Header "Packages & Software"

# Install / Upgrade VSCode
Write-Host "Installing / Updating VSCode..."
Invoke-Command-Surround-Output choco upgrade vscode -y

# Install / Upgrade AutoHotkey
Write-Host "Installing / Updating AutoHotkey..."
Invoke-Command-Surround-Output choco upgrade autohotkey -y

# Install / Upgrade OBS
Write-Host "Installing / Updating OBS..."
Invoke-Command-Surround-Output choco upgrade obs-studio -y

# Install / Upgrade foobar2000
Write-Host "Installing / Updating foobar2000..."
Invoke-Command-Surround-Output choco upgrade foobar2000 -y

# Install / Upgrade X AIR Edit
Write-Host "Installing / Updating X AIR Edit..."
Invoke-Command-Surround-Output choco upgrade x-air-edit -y

# Install / Upgrade NodeJS LTS
Write-Host "Installing / Updating NodeJS (LTS)..."
Invoke-Command-Surround-Output choco upgrade nodejs-lts -y

Set-Environment
if ( -not (Get-Command npm -errorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Red "NPM not found in PATH - check NodeJS installation"
    Write-Host "This is a problem, but might be solved by just trying again."
    Write-Host -ForegroundColor Yellow "If you see this error repeatedly - talk to a (very) Senior Tech!"
    Exit-After-Keypress
}

Write-Host "Installing / Updating NPM..."
Invoke-Command-Surround-Output npm install -g npm

Write-Host "Installing / Updating Bower..."
Invoke-Command-Surround-Output npm install -g bower

# Install / Upgrade NodeCG
Write-Header "NodeCG Install & Configuration"
Write-Host "Installing / Updating NodeCG CLI..."
Invoke-Command-Surround-Output npm install -g nodecg-cli

if (-not (Test-Path -Path $PSScriptRoot\nodecg)) {
    Write-Host "Creating NodeCG Directory..."
    New-Item -Path $PSScriptRoot -Name "nodecg" -ItemType "directory"
    Write-Host "First time NodeCG Setup..."
    Set-Location -Path $PSScriptRoot\nodecg
    Invoke-Command-Surround-Output nodecg setup
}

Set-Location -Path $PSScriptRoot\nodecg

Write-Host "Installing / Updating nodecg-speedcontrol..."

# Manual Steps
Write-Header "Manual Installation Steps"

# Finished
Write-Header "All Done!"
Write-Host -ForegroundColor Green "UKSG Installer / Updater has completed!"
Exit-After-Keypress
