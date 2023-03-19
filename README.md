# UKSG Tech PC - Scripts and Configuration

## Setting up a completely fresh PC
1. Create a directory somewhere to hold everything (normally a directory on the Desktop works well!)
2. In an Administrator Powershell, run this command:
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/skenmy/uksg-tech/main/InitScript.ps1'))
```
3. When prompted, select the directory created in Step 1.
4. When finished, open the directory you created and you will find all the scripts! See below for instructions!

## Using the Scripts
### 1-RegistryTweaks.reg
Run this first. It makes some simple tweaks to the Windows Registry to enable some features that are important.

### InstallUpdate.ps1
**NOTE:** This must be run in an Administrator Powershell _(if you've run 1-RegistryTweaks.reg, you can Right Click -> Run as administrator)_

This script will first try to update itself, then will run through and install / update all required software for the PC. Follow any instructions given. The script will also do some automatic configuration of software - so you may see applications launch, do things, and close. This is normal. The script will tell you when it is done.

### InitScript.ps1
**NOTE:** It is not advised to run this script on anything except a completely unconfigured PC!

This script performs initial setup of a PC that has not been configured. It downloads this repository to the local machine.
