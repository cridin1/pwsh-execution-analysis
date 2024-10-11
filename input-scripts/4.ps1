$ProgramPath = "C:\Users\admin\Desktop\Start.exe"

$Action = New-ScheduledTaskAction -Execute $ProgramPath

$Trigger = New-ScheduledTaskTrigger -AtStartup

$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest

Register-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -TaskName "MyProgram Task" -Description "This task runs MyProgram.exe with administrator privileges."