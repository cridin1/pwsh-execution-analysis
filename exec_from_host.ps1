param(
    [string]$outdir = "output",
    [string]$path_commands = "example.out"
)

mkdir $pwd\$outdir

$VMName = "Malware-VM-Windows"
$base_path="C:\Users\unina\Desktop\tesi\pwsh-execution-analysis"
$setup_path = "$base_path\setup.ps1"
$analysis_path = "$base_path\exec-analysis.ps1"

#Starting the test
VBoxManage snapshot $VMName restore e87ea332-d6ec-4e0b-bcc1-8b34697431ad
VBoxManage startvm $VMName --type headless

$started = $false
while($started -eq $false){
    try{
        Write-Host "Trying to start VM..."
        $result = VBOxManage guestcontrol $VMName copyto --username Administrator --password unina --target-directory="$base_path\" $pwd\$path_commands 2>&1 | Out-String
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

Write-Host "Vm Started and ready to execute commands"
VBOxManage guestcontrol $VMName --username Administrator --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /file $setup_path  --wait-stdout
Start-Sleep -Seconds 3

$commands = Split-Path $path_commands -leaf
Write-Host "Executing the analysis..."
VBOxManage guestcontrol $VMName --username Administrator --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command "$analysis_path $commands > $base_path\log.txt" --wait-stdout

#--exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command "& {Start-Process powershell -Verb RunAs -Command '$analysis_path $path_commands > $base_path\log.txt'}" --wait-stdout

#"Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\setup.ps1""' -Verb RunAs"

#VBoxManage guestcontrol $VMName execute --image "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" --username unina --password unina --wait-exit --wait-stdout --powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\setup.ps1"
#VBoxManage guestcontrol $VMName run --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" --username $Username --password $Password --wait-stdout --powershell -NoProfile -ExecutionPolicy Bypass -File "$ScriptPath"

Start-Sleep -Seconds 3
#saving files
VBOxManage guestcontrol $VMName copyfrom --username Administrator --password unina --verbose --recursive --target-directory="$pwd\$outdir" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\output
VBOxManage guestcontrol $VMName copyfrom --username Administrator --password unina --verbose --target-directory="$pwd\$outdir\" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\log.txt

#save snapshot
#VBoxManage snapshot "Malware-VM-Windows" take $1 --description "Execution of test $1"
VBoxManage controlvm $VMName acpipowerbutton --verbose