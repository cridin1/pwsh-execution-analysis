$VMName = "Malware-VM-Windows"
$base_path="C:\Users\unina\Desktop\tesi\pwsh-execution-analysis"

VBOxManage guestcontrol $VMName --username unina --password unina run --exe `
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "Get-Content -Path $base_path\output\log.txt -Wait"