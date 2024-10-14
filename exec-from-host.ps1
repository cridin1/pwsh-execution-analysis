param(
     [Parameter()]
     [string]$output_dir = "output",

     [Parameter()]
     [string]$input_dir = "input-scripts",

     [Parameter()]
     [string]$snapshot = "b7a5cb3a-3952-4703-a1db-cbcf93357f6e"

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

mkdir $pwd\$output_dir

$VMName = "Malware-VM-Windows"
$base_path="C:\Users\unina\Desktop\tesi\pwsh-execution-analysis"
$analysis_path = "$base_path\exec-analysis-scripts.ps1"

#Starting the test
VBoxManage snapshot $VMName restore $snapshot
VBoxManage startvm $VMName --type headless
Start-Sleep -Seconds 30

$started = $false
while($started -eq $false){
    try{
        Write-Host "Trying to start VM..."
        $result = VBOxManage guestcontrol $VMName copyto --R --username unina --password unina --target-directory="$base_path\" $input_dir 2>&1 | Out-String
        $started = (-not ($result -Match "error"))
        Write-Host "VM started? " $started $result
        Start-Sleep -Seconds 30
    }
    catch{
        Write-Host $error[0].Exception.Message
        Write-Host "VM not yet started..."
        Start-Sleep -Seconds 10
    }
}

Write-Host "Vm Started and ready to execute commands"

$commands = Split-Path $input_dir -leaf
Write-Host "Executing the analysis..."
VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command "$analysis_path $commands > $base_path\log.txt" --no-wait-stdout

Start-Sleep -Seconds 10
#saving files
VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose --recursive --target-directory="$pwd\$output_dir" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\output
VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose --target-directory="$pwd\$output_dir\" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\log.txt

#save snapshot
VBoxManage controlvm $VMName acpipowerbutton --verbose

