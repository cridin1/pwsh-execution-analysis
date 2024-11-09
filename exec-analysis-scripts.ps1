param(
    [string]$path_scripts = "input-scripts",
    [string]$outdir = "output",
    [string]$config_file = "sysmon-configs\sysmonconfig-excludes-only.xml"
)

$pwd_base="C:\Users\unina\Desktop\tesi\pwsh-execution-analysis"
$outdir = "$pwd_base\$outdir"
$config_file = "$pwd_base\$config_file"

Import-Module Logging
$level = 'INFO'
Set-LoggingDefaultLevel -Level $level
Add-LoggingTarget -Name File @{
    Path            = "$pwd_base\output\log.txt"                                             
    PrintBody       = $false             
    PrintException  = $false              
    Append          = $true              
    Encoding        = 'ascii'            
    Level           = $level            
  
}

Function Parse-Event {
    # Credit: https://github.com/RamblingCookieMonster/PowerShell/blob/master/Get-WinEventData.ps1
    param(
        [Parameter(ValueFromPipeline=$true)] $Event
    )

    Process
    {
        foreach($entry in $Event)
        {
            $XML = [xml]$entry.ToXml()
            $X = $XML.Event.EventData.Data
            For( $i=0; $i -lt $X.count; $i++ ){
                $Entry = Add-Member -InputObject $entry -MemberType NoteProperty -Name "$($X[$i].name)" -Value $X[$i].'#text' -Force -Passthru
            }
            $Entry
        }
    }
}

Function Write-alert($alerts) {
    Write-Log -Level "INFO" -Message  "Type: $($alerts.Type)"
    $alerts.Remove("Type")
    foreach($alert in $alerts.GetEnumerator()) {
        Write-Log -Level "INFO" -Message  "$($alert.Name): $($alert.Value)"
    }
    Write-Log -Level "INFO" -Message  "-----"
}

Function Print-Logs($logs){
    foreach ($log in $logs) {
        $evt = $log | Parse-Event
        if ($evt.id -eq 1) {
            $output = @{}
            $output.add("Type", "Process Create")
            $output.add("PID", $evt.ProcessId)
            $output.add("Image", $evt.Image)
            $output.add("CommandLine", $evt.CommandLine)
            $output.add("CurrentDirectory", $evt.CurrentDirectory)
            $output.add("User", $evt.User)
            $output.add("ParentImage", $evt.ParentImage)
            $output.add("ParentCommandLine", $evt.ParentCommandLine)
            $output.add("ParentUser", $evt.ParentUser)
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 2) {
            $output = @{}
            $output.add("Type", "File Creation Time Changed")
            $output.add("PID", $evt.ProcessId)
            $output.add("Image", $evt.Image)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("CreationUtcTime", $evt.CreationUtcTime)
            $output.add("PreviousCreationUtcTime", $evt.PreviousCreationUtcTime)
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 3) {
            $output = @{}
            $output.add("Type", "Network Connection")
            $output.add("Image", $evt.Image)
            $output.add("DestinationIp", $evt.DestinationIp)
            $output.add("DestinationPort", $evt.DestinationPort)
            $output.add("DestinationHost", $evt.DestinationHostname)
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 5) {
            $output = @{}
            $output.add("Type", "Process Ended")
            $output.add("PID", $evt.ProcessId)
            $output.add("Image", $evt.Image)
            $output.add("CommandLine", $evt.CommandLine)
            $output.add("CurrentDirectory", $evt.CurrentDirectory)
            $output.add("User", $evt.User)
            $output.add("ParentImage", $evt.ParentImage)
            $output.add("ParentCommandLine", $evt.ParentCommandLine)
            $output.add("ParentUser", $evt.ParentUser)
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 6) {
            $output = @{}
            $output.add("Type", "Driver Loaded")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 7) {
            $output = @{}
            $output.add("Type", "DLL Loaded By Process")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 8) {
            $output = @{}
            $output.add("Type", "Remote Thread Created")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 9) {
            $output = @{}
            $output.add("Type", "Raw Disk Access")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 10) {
            $output = @{}
            $output.add("Type", "Inter-Process Access")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 11) {
            $output = @{}
            $output.add("Type", "File Create")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 12) {
            $output = @{}
            $output.add("Type", "Registry Added or Deleted")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 13) {
            $output = @{}
            $output.add("Type", "Registry Set")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 14) {
            $output = @{}
            $output.add("Type", "Registry Object Renamed")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 15) {
            $output = @{}
            $output.add("Type", "ADFS Created")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 16) {
            $output = @{}
            $output.add("Type", "Sysmon Configuration Change")
            Write-Log -Level "DEBUG" -Message $output
        }
        if ($evt.id -eq 17) {
            $output = @{}
            $output.add("Type", "Pipe Created")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 18) {
            $output = @{}
            $output.add("Type", "Pipe Connected")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 19) {
            $output = @{}
            $output.add("Type", "WMI Event Filter Activity")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 20) {
            $output = @{}
            $output.add("Type", "WMI Event Consumer Activity")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 21) {
            $output = @{}
            $output.add("Type", "WMI Event Consumer To Filter Activity")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 22) {
            $output = @{}
            $output.add("Type", "DNS Query")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 23) {
            $output = @{}
            $output.add("Type", "File Delete")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 24) {
            $output = @{}
            $output.add("Type", "Clipboard Event Monitor")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 25) {
            $output = @{}
            $output.add("Type", "Process Tamper")
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        if ($evt.id -eq 26) {
            $output = @{}
            $output.add("Type", "File Delete Logged")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            Write-Log -Level "DEBUG" -Message  $output.type -Body $output 
        }
        $maxRecordId = $evt.RecordId
    }

}

Function Create-PowerShell-Process ($input_file, $output_file, $timeout = 30000){
    $Process = New-Object System.Diagnostics.Process

    $ProcessStartInfoParam = [ordered]@{
        Arguments              = "-NonInteractive -File $input_file"
        CreateNoWindow         = $False
        FileName               = 'pwsh'
        WindowStyle            = 'Hidden'
        LoadUserProfile        = $False
        UseShellExecute        = $False
        RedirectStandardOutput = $True
        RedirectStandardError  = $True
    }

    $ProcessStartInfo = New-Object -TypeName 'System.Diagnostics.ProcessStartInfo' -Property $ProcessStartInfoParam 
    $Process.StartInfo = $ProcessStartInfo
    $Process.Start()
    $id = $Process.Id
    $Output = $null

    if ($Process.WaitForExit($timeout)) {
        # Process exited within the timeout
        $Output = $Process.StandardOutput.ReadToEnd()
        $Output | Out-File -FilePath $output_file -Encoding ASCII | Out-Null
    } else {
        # Process timed out
        Write-Log -Level 'WARNING' -Message "Process $id did not complete within the timeout period. Terminating process."
        $Process.Kill()
        $Process.WaitForExit()  # Ensure it fully exits after being killed
        $Output = $Process.StandardError.ReadToEnd()
        $Output | Out-File -FilePath $output_file -Encoding ASCII | Out-Null
    }
    return $Process
}

Function Export-Logs($directory){
    $i = 0
    $LogName = "Microsoft-Windows-Sysmon/Operational"
    $Provider = "Microsoft-Windows-Sysmon"
    $maxRecordId = (Get-WinEvent -Provider $Provider -max 1).RecordID
    $length = $directory.Length


    foreach ($input_file in $directory)
    {
        $name = $input_file.FullName
        $id_sample = $input_file.BaseName

        Start-Sleep 1
        $i = $i + 1
        Write-Progress -PercentComplete ($i/$length*100) -Status "Processing Script $id_sample" -Activity "$i of $length"
        $maxRecordId = (Get-WinEvent -Provider $Provider -max 1).RecordID
        
        Write-Log -Level "INFO" -Message  "Executing {$id_sample}: $name"

        $Process = Create-PowerShell-Process $name "$outdir\txt\$id_sample.txt"
        $id = $Process.Id
        Write-Log -Level "INFO" -Message  "Executed {$id_sample} "
    
        $XPath="*[System[EventRecordID > $maxRecordId]]"
        try{
            $XPath_child = "*[System[EventRecordID > $maxRecordId] and EventData[Data[@Name='ParentProcessId'] = $id]]"
            $child_logs = Get-WinEvent -Provider $Provider -FilterXPath  $XPath_child -ErrorAction Stop | Select-Object -Property @{Name="Process Id";Expression={$_.Properties[3].Value}}
            $ids = $child_logs."Process Id"
            
            $XPath = "*[System[EventRecordID > $maxRecordId] and EventData[ Data[@Name='ProcessId'] = $id or "
            $j = 0
            foreach($id in $ids){
                if($j -eq 0){
                    $XPath += "Data[@Name='ProcessId'] = $id "
                }
                else{
                    $XPath += " or Data[@Name='ProcessId'] = $id "
                }
                $j++
            }
            $XPath += "]]"
            Write-Log -Level "DEBUG" -Message "{0}" -Arguments $XPath
        
        }
        catch{
             $XPath = "*[System[EventRecordID > $maxRecordId] and EventData[Data[@Name='ParentProcessId'] = $id or Data[@Name='ProcessId'] = $id]]"
        }
 
        $SourceType = "LogName"
        $EvtSession = [System.Diagnostics.Eventing.Reader.EventLogSession]::New()
        try{
            $EvtSession.ExportLog($LogName, [System.Diagnostics.Eventing.Reader.PathType]::$SourceType, $XPath, "$outdir\evtx\$id_sample.evtx")
        }
        catch{
            Write-Log -Level "ERROR" -Message "Error on exportation of evtx"
            $EvtSession.Dispose()
            return
        }

        $EvtSession.ClearLog($LogName)
        $EvtSession.Dispose()
        $logs = Get-WinEvent -Path "$outdir\evtx\$id_sample.evtx"

        $xml = [xml]((wevtutil query-events "$outdir\evtx\$id_sample.evtx" /logfile /element:root) -replace "\x01","" -replace "\x0f","" -replace "\x02","" -replace "\x1C","" -replace "\x0F", "")
        $xml.Save("$outdir\xml\$id_sample.xml")

        Print-Logs $logs
    }
}


Function Start-Analysis($path_scripts = "$pwd_base\inputs", $outdir = "$pwd_base\output"){
    whoami

    Write-Host "Starting analysis: $path_scripts"

    if (!(Test-Path "$outdir")) {
        New-Item -ItemType Directory -Path "$outdir"
    }

    if (!(Test-Path "$outdir\evtx")) {
        New-Item -ItemType Directory -Path "$outdir\evtx"
    }
    else{
        Write-Log -Level $level -Message "Alreadyy present evtx directory"
        Write-Host "Already present evtx directory"
        return
    }

    if (!(Test-Path "$outdir\txt")) {
        New-Item -ItemType Directory -Path "$outdir\txt"
    }

    if (!(Test-Path "$outdir\xml")) {
        New-Item -ItemType Directory -Path "$outdir\xml"
    }

    #clearing dns
    ipconfig /flushdns

    Write-Log -Level $level -Message "Importing cmds"
	Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\malicious-cmds

	Write-Log -Level $level -Message "Importing Powersploit"
	Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Powersploit

	Write-Log -Level $level -Message "All imported"
	

    Write-Log -Level $level -Message "Executing sysmon: "
    sysmon.exe -accepteula -i $config_file

    $lines = Get-ChildItem -Path $path_scripts -File
    Export-Logs($lines)
    
    Write-Log -Level $level -Message "Uninstalling sysmon: "
    sysmon.exe -u
}

Start-Analysis $path_scripts $outdir