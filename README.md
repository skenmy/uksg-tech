# uksg-tech

## Setting up a completely fresh PC
In an Administrator Powershell:
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/skenmy/uksg-tech/main/InitScript.ps1'))
```
