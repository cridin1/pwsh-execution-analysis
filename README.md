Inspired by:

https://github.com/IppSec/PowerSiem.git 

https://github.com/Neo23x0/sysmon-config.git 

1 Download mimikatz from https://github.com/ParrotSec/mimikatz.git 
  and powersploit from https://github.com/PowerShellMafia/PowerSploit.git

2 Move powersploit in C:\Windows\System32\WindowsPowerShell\v1.0\Modules

3 Add mimikatz.exe to env var PATH

4 Use PSVersion  5.1.19041.1645

Make sure to use pwsh as admin:

`.\exec-analysis.ps1 $pwd\example2.txt $pwd\output1`

