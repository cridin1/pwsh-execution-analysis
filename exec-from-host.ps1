param(
     [Parameter()]
     [string]$output_dir = "output3",

     [Parameter()]
     [string]$input_dir = "C:\Users\super\Desktop\tesi_magistrale\zircolite-test\data\data\test",

     [Parameter()]
     [string]$snapshot = "9abcbaf7-3311-45fd-bfca-e7ada9904a81"

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

Write-Host "Waiting the VM..."
$started = $false
while($started -eq $false){
    try{
        Write-Host "Waiting the VM..."
        $result = VBOxManage guestcontrol $VMName --username unina --password unina run --exe `
        cmd.exe /c "git --git-dir=$base_path\.git --work-tree=$base_path pull > $base_path\git-pull.log 2>&1"

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
VBOxManage guestcontrol $VMName copyto --recursive --username unina --password unina `
--target-directory="$base_path\inputs" $input_dir 2>&1 | Out-String
Start-Sleep -Seconds 10

Write-Host "VM Executing setup script"
VBOxManage guestcontrol $VMName --username unina --password unina run `
--exe "C:\Program Files\PowerShell\7\pwsh.exe" "$setup_path"

Start-Sleep -Seconds 20

Write-Host "VM Executing the analysis..."
$input_path = "$base_path\inputs"
VBOxManage guestcontrol $VMName --username unina --password unina run `
--exe "C:\Program Files\PowerShell\7\pwsh.exe" /command "$analysis_path $input_path"

Start-Sleep -Seconds 10
#saving files
Write-Host "VM Zipping output..."
VBOxManage guestcontrol $VMName --username unina --password unina run `
--exe "C:\Program Files\PowerShell\7\pwsh.exe" /command `
"Compress-Archive $base_path\output -DestinationPath $base_path\output.zip"

VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose `
--recursive --target-directory="$pwd\" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\output.zip

Expand-Archive -Path "$pwd\output.zip" -DestinationPath $output_dir -Force
rm "$pwd\output.zip"

#save snapshot
VBoxManage controlvm $VMName acpipowerbutton --verbose

