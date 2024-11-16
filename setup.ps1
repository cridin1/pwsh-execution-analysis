push-location \
$directoryToAdd = "$pwd\mimikatz\x64"

# Check if the directory is already in the PATH
if (-not ($env:PATH -like "*$directoryToAdd*")) {
    # Add the directory to the PATH
    git clone https://github.com/ParrotSec/mimikatz.git
    $env:PATH += ";$directoryToAdd"

    # Optionally, update the system PATH as well (requires elevated privileges)
    [System.Environment]::SetEnvironmentVariable("PATH", $env:PATH, [System.EnvironmentVariableTarget]::Machine)

    Write-Host "Directory added to PATH: $directoryToAdd"
} else {
    Write-Host "Directory is already in PATH: $directoryToAdd"
}

$directoryToAdd = "$pwd\Sysmon"
# Check if the directory is already in the PATH
if (-not ($env:PATH -like "*$directoryToAdd*")) {
    # Add the directory to the PATH
    Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -Outfile Sysmon.zip
    Expand-Archive Sysmon.zip
    $env:PATH += ";$directoryToAdd"
    # Optionally, update the system PATH as well (requires elevated privileges)
    [System.Environment]::SetEnvironmentVariable("PATH", $env:PATH, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Directory added to PATH: $directoryToAdd"
} else {
    Write-Host "Directory is already in PATH: $directoryToAdd"
}

#check if cmds is in modules
if (-not (Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\malicious-cmds")) {
    Write-Host "Cmds not found, installing"
    Copy-Item -r C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\malicious-cmds C:\Windows\System32\WindowsPowerShell\v1.0\Modules
} else {
    Write-Host "Cmds found, skipping"
}

#check if powersploit is in modules
if (-not (Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PowerSploit")) {
    Write-Host "Powersploit not found, installing"
    git clone https://github.com/PowerShellMafia/PowerSploit.git

    rm Powersploit/Exfiltration/Invoke-Mimikatz.ps1
    mv Powersploit C:\Windows\System32\WindowsPowerShell\v1.0\Modules
} else {
    Write-Host "Powersploit found, skipping"
}

Write-Host "Installing Logging module"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Logging -Force

Write-Host "Enabling Powershell core logging frrom gpo settings"

Copy-item "C:\Program Files\PowerShell\7\PowerShellCoreExecutionPolicy.admx" -Destination "C:\Windows\PolicyDefinitions" -Force
Copy-item "C:\Program Files\PowerShell\7\PowerShellCoreExecutionPolicy.adml" -Destination "C:\Windows\PolicyDefinitions\en-US" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\PowerShellCore\ModuleLogging" -Name "EnableModuleLogging" -Value 1 -Force
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Powershell\ModuleLogging" -Name "ModuleNames"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Powershell\ModuleLogging\ModuleNames" -Name "*" -Value "*"

Write-Host "Setup completed"

pop-location




