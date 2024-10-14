$uninstall32s = Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | 
    foreach { Get-ItemProperty $_.PSPath } | 
    Where-Object { $_ -like "*AVG*" } | 
    Select-Object UninstallString;

$uninstall64s = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | 
    foreach { Get-ItemProperty $_.PSPath } |
    Where-Object { $_ -like "*AVG*" } | 
    Select-Object UninstallString;

foreach($uninstall64 in $uninstall64s) {
    $uninstall64 = $uninstall64.UninstallString -Replace "MsiExec.exe","" -Replace "/I","" -Replace "/X","";
    $uninstall64 = $uninstall64.Trim();
    if($uninstall64 -like "*/mode=offline*"){}
    else {
        Write-Warning $uninstall64; 
        Start-Process "msiexec.exe" -ArgumentList "/x $uninstall64  /qn /norestart" -Wait 
    }
};

foreach($uninstall32 in $uninstall32s) {
    $uninstall32 = $uninstall32.UninstallString -Replace "MsiExec.exe","" -Replace "/I","" -Replace "/X","";
    $uninstall32 = $uninstall32.Trim();
    if($uninstall32 -like "*/mode=offline*"){}
    else {
        Write-Warning $uninstall32; 
        Start-Process "msiexec.exe" -ArgumentList "/x $uninstall32  /qn /norestart" -Wait 
    }
};