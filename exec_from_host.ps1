param(
    [string]$outdir = "output",
    [string]$path_commands = "example.txt"
)

mkdir $pwd\$outdir

$VMName = "Malware-VM-Windows"
$base_path="C:\Users\unina\Desktop\tesi\pwsh-execution-analysis"
$setup_path = "$base_path\setup.ps1"
$analysis_path = "$base_path\exec-analysis.ps1"

#Starting the test
VBoxManage snapshot $VMName restore 9c60e767-bfd1-4ecf-a8fe-b6297936b340
VBoxManage startvm $VMName --type headless

Start-Sleep -Seconds 10

VBOxManage guestcontrol $VMName copyto --username unina --password unina --target-directory="$base_path\" $pwd\$path_commands
VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /file $setup_path  --wait-stdout
VBOxManage guestcontrol $VMName --username unina --password unina run --exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /command "$analysis_path $path_commands > $base_path\log.txt" --wait-stdout

sleep 2
#saving files
VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose --recursive --target-directory="$pwd\$outdir" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\output
VBOxManage guestcontrol $VMName copyfrom --username unina --password unina --verbose --target-directory="$pwd\$outdir\" C:\Users\unina\Desktop\tesi\pwsh-execution-analysis\log.txt

#save snapshot
#VBoxManage snapshot "Malware-VM-Windows" take $1 --description "Execution of test $1"
VBoxManage controlvm $VMName acpipowerbutton --verbose