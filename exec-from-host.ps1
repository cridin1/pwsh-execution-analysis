param(
     [Parameter()]
     [string]$output_dir = "output",

     [Parameter()]
     [string]$input_dir = "input-scripts",

     [Parameter()]
     [string]$snapshot = "d32e78f5-df4e-498f-9750-e6db64901097"

 )

write-host 
"""

                   _                              
 _ ____      _____| |__         _____  _____  ___ 
| '_ \ \ /\ / / __| '_ \ _____ / _ \ \/ / _ \/ __|
| |_) \ V  V /\__ \ | | |_____|  __/>  <  __/ (__ 
| .__/ \_/\_/ |___/_| |_|      \___/_/\_\___|\___|
|_|                                               

 
"""






$VMName = "Malware-VM-Windows"
$base_path="C:\Users\unina\Desktop\tesi\pwsh-execution-analysis"
$setup_path = "$base_path\setup.ps1"
$analysis_path = "$base_path\exec-analysis-scripts.ps1"

#Starting the test
VBoxManage snapshot $VMName restore $snapshot
VBoxManage startvm $VMName --type headless
Start-Sleep -Seconds 30

$started = $false
while($started -eq $false){
    try{
        Write-Host "Waiting the VM..."
        $result = VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command "git -C $base_path pull" --no-wait-stdout > $null 2>&1
        $started = (-not ($result -Match "error"))
        Write-Host "VM started? " $started $result
        Start-Sleep -Seconds 10
    }
    catch{
        Write-Host $error[0].Exception.Message
        Write-Host "VM not yet started..."
        Start-Sleep -Seconds 10
    }
}

Write-Host "VM Started and copying inputs..."
VBOxManage guestcontrol $VMName copyto --recursive --username unina --password unina --target-directory="$base_path\" $pwd\$input_dir 2>&1 | Out-String
Start-Sleep -Seconds 10

Write-Host "VM Executing setup script"
VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command "$setup_path"
Start-Sleep -Seconds 10

$commands = Split-Path $input_dir -leaf
Write-Host "VM Executing the analysis..."
VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command "$analysis_path $commands > $base_path\log.txt" --no-wait-stdout

Start-Sleep -Seconds 10
#saving files

VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command  "Compress-Archive $base_path\output -DestinationPath $base_path\output.zip"
VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose --recursive --target-directory="$pwd\" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\output.zip
Expand-Archive -Path "$pwd\output.zip"
rm "$pwd\output.zip"

VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose --target-directory="$pwd\$output_dir\" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\log.txt

#save snapshot
VBoxManage controlvm $VMName acpipowerbutton --verbose

