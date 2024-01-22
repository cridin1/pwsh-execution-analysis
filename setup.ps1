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

#check if powersploit is in modules
if (-not (Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PowerSploit")) {
    Write-Host "Powersploit not found, installing"
    git clone https://github.com/PowerShellMafia/PowerSploit.git

    rm Powersploit/Exfiltration/Invoke-Mimikatz.ps1
    mv Powersploit C:\Windows\System32\WindowsPowerShell\v1.0\Modules
} else {
    Write-Host "Powersploit found, skipping"
}

pop-location




