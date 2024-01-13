param(
    [string]$config_file = "sysmonconfig-excludes-only.xml"
)

function Export-WinEvent {
    <#
    .SYNOPSIS
        Export events that match a given query in to a Evtx file.
    .DESCRIPTION
        Export events that match a given query in to a Evtx file. Supports as source a log by Log Name or from another Evtx file. Query has to be in XPath format.
    .EXAMPLE
        PS C:\> [string]$query = $($Output = Get-SysmonProcessAccess -TargetImage "C:\WINDOWS\system32\lsass.exe" -verbose -MaxEvents 1) 4>&1
        PS C:\> Export-WinEvent -SourcePath "Microsoft-Windows-Sysmon/Operational" -Path C:\LSASSProcessAccess.evtx -Query $query
 
        Capture the XPath query from one of the Sysmon PSGumshoe functions and use that to export the resulting events into a file.
        Technique also works with Get-WinEvent.
    .INPUTS
        System.String
    .NOTES
        Xpath Query EventLog use and limitations https://docs.microsoft.com/en-us/windows/win32/wes/consuming-events
    #>
    [CmdletBinding(DefaultParameterSetName = "Local")]
    param (
        # Source to export from.
        [Parameter(Mandatory=$true)]
        [String]
        $SourcePath,

        # Type of source. (File or EventLog)
        [Parameter(Mandatory=$false)]
        [ValidateSet("FilePath","LogName")]
        [String]
        $SourceType ="LogName",

        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
                   Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,

        # The query used to select the events to export. Only the events returned from the query will be exported. Queries are represented in MS Eventlog XPath.
        [Parameter(Mandatory = $true)]
        [String]
        $Query,

        # Clear a given EventLog from the specified computer. Type the NetBIOS name, an Internet Protocol (IP) address, or the fully qualified domain name of the computer.
        # To get events and event logs from remote computers, the firewall port for the event log service must be configured to allow remote access.
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   ParameterSetName = 'Remote')]
        [string]
        $ComputerName,

        # Specifies a user account that has permission to perform this action.
        #
        # Type a user name, such as User01 or Domain01\User01. Or, enter a PSCredential object, such as one generated by the Get-Credential cmdlet. If you type a user name, you will
        # be prompted for a password. If you type only the parameter name, you will be prompted for both a user name and a password.
        [Parameter(Mandatory = $false,
                   ParameterSetName = 'Remote')]
        [Management.Automation.PSCredential]
        [Management.Automation.CredentialAttribute()]
        $Credential
        
    )
    
    begin {
        
    }
    
    process {

        switch ($PSCmdlet.ParameterSetName) {
            "Local" { 
                $EvtSession = [System.Diagnostics.Eventing.Reader.EventLogSession]::New()
            }
            "Remote" { 
                if ($PSBoundParameters.Keys -contains "Credential") {
                    $EvtSession = [System.Diagnostics.Eventing.Reader.EventLogSession]::New($ComputerName, $Credential.Username, $Credential.GetNetworkCredential().password )
                } else {
                    $EvtSession = [System.Diagnostics.Eventing.Reader.EventLogSession]::New($ComputerName)
                }
             }
            Default {}
        }
        #sort by eventid

        $EvtSession.ExportLog($SourcePath, [System.Diagnostics.Eventing.Reader.PathType]::$SourceType, $Query, $Path)
        
    }
    
    end {
        
    }
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

Function Write-Alert ($alerts) {
    Write-Host "Type: $($alerts.Type)"
    $alerts.Remove("Type")
    foreach($alert in $alerts.GetEnumerator()) {
        write-host "$($alert.Name): $($alert.Value)"
    }
    write-host "-----"
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
            write-alert $output
        }
        if ($evt.id -eq 2) {
            $output = @{}
            $output.add("Type", "File Creation Time Changed")
            $output.add("PID", $evt.ProcessId)
            $output.add("Image", $evt.Image)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("CreationUtcTime", $evt.CreationUtcTime)
            $output.add("PreviousCreationUtcTime", $evt.PreviousCreationUtcTime)
            write-alert $output
        }
        if ($evt.id -eq 3) {
            $output = @{}
            $output.add("Type", "Network Connection")
            $output.add("Image", $evt.Image)
            $output.add("DestinationIp", $evt.DestinationIp)
            $output.add("DestinationPort", $evt.DestinationPort)
            $output.add("DestinationHost", $evt.DestinationHostname)
            write-alert $output
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
            write-alert $output
        }
        if ($evt.id -eq 6) {
            $output = @{}
            $output.add("Type", "Driver Loaded")
            write-alert $output
        }
        if ($evt.id -eq 7) {
            $output = @{}
            $output.add("Type", "DLL Loaded By Process")
            write-alert $output
        }
        if ($evt.id -eq 8) {
            $output = @{}
            $output.add("Type", "Remote Thread Created")
            write-alert $output
        }
        if ($evt.id -eq 9) {
            $output = @{}
            $output.add("Type", "Raw Disk Access")
            write-alert $output
        }
        if ($evt.id -eq 10) {
            $output = @{}
            $output.add("Type", "Inter-Process Access")
            write-alert $output
        }
        if ($evt.id -eq 11) {
            $output = @{}
            $output.add("Type", "File Create")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            write-alert $output
        }
        if ($evt.id -eq 12) {
            $output = @{}
            $output.add("Type", "Registry Added or Deleted")
            write-alert $output
        }
        if ($evt.id -eq 13) {
            $output = @{}
            $output.add("Type", "Registry Set")
            write-alert $output
        }
        if ($evt.id -eq 14) {
            $output = @{}
            $output.add("Type", "Registry Object Renamed")
            write-alert $output
        }
        if ($evt.id -eq 15) {
            $output = @{}
            $output.add("Type", "ADFS Created")
            write-alert $output
        }
        if ($evt.id -eq 16) {
            $output = @{}
            $output.add("Type", "Sysmon Configuration Change")
            write-alert $output
        }
        if ($evt.id -eq 17) {
            $output = @{}
            $output.add("Type", "Pipe Created")
            write-alert $output
        }
        if ($evt.id -eq 18) {
            $output = @{}
            $output.add("Type", "Pipe Connected")
            write-alert $output
        }
        if ($evt.id -eq 19) {
            $output = @{}
            $output.add("Type", "WMI Event Filter Activity")
            write-alert $output
        }
        if ($evt.id -eq 20) {
            $output = @{}
            $output.add("Type", "WMI Event Consumer Activity")
            write-alert $output
        }
        if ($evt.id -eq 21) {
            $output = @{}
            $output.add("Type", "WMI Event Consumer To Filter Activity")
            write-alert $output
        }
        if ($evt.id -eq 22) {
            $output = @{}
            $output.add("Type", "DNS Query")
            write-alert $output
        }
        if ($evt.id -eq 23) {
            $output = @{}
            $output.add("Type", "File Delete")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            write-alert $output
        }
        if ($evt.id -eq 24) {
            $output = @{}
            $output.add("Type", "Clipboard Event Monitor")
            write-alert $output
        }
        if ($evt.id -eq 25) {
            $output = @{}
            $output.add("Type", "Process Tamper")
            write-alert $output
        }
        if ($evt.id -eq 26) {
            $output = @{}
            $output.add("Type", "File Delete Logged")
            $output.add("RecordID", $evt.RecordID)
            $output.add("TargetFilename", $evt.TargetFileName)
            $output.add("User", $evt.User)
            $output.add("Process", $evt.Image)
            $output.add("PID", $evt.ProcessID)
            write-alert $output
        }
        $maxRecordId = $evt.RecordId
    }

}

Function Create-PowerShell-Process($command, $output_file){
    $Process = New-Object System.Diagnostics.Process
    $ProcessStartInfoParam = [ordered]@{
        Arguments              = " { $command } > $output_file | out-null"
        CreateNoWindow         = $False
        FileName               = 'pwsh'
        WindowStyle            = 'Hidden'
        LoadUserProfile        = $False
        UseShellExecute        = $False
        
    }

    $ProcessStartInfo = New-Object -TypeName 'System.Diagnostics.ProcessStartInfo' -Property $ProcessStartInfoParam
    $Process.StartInfo = $ProcessStartInfo
    $StartResult = $Process.Start()
    $Process.WaitForExit()

    return $Process
}

Function Export-Logs($lines){
    $i = 0
    $LogName = "Microsoft-Windows-Sysmon/Operational"

    foreach ($line in $lines)
    {
        $i = $i + 1
        Start-Sleep 1

        Write-Host "Executing {$i}: $line"
        $Process = Create-PowerShell-Process $line "$pwd\txt\output$i.txt"
        $id = $Process.Id
        $image = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

        $xPath="*[EventData[Data[@Name='ProcessId'] = $id and Data[@Name='Image'] = '$image']]"
        Export-WinEvent -SourcePath $LogName -Path "$pwd\evtx\output$i.evtx" -Query $XPath
        $logs = Get-WinEvent -Path "$pwd\evtx\output$i.evtx"
        Print-Logs $logs

    }

}

Function Start-Analysis(){
    if (!(Test-Path "$pwd\evtx")) {
        New-Item -ItemType Directory -Path "$pwd\evtx"
    }

    if (!(Test-Path "$pwd\txt")) {
        New-Item -ItemType Directory -Path "$pwd\txt"
    }

    Write-Host "Executing sysmon: "
    sysmon.exe -accepteula -i $config_file

    $lines = Get-Content -Path "example.txt"
    Export-Logs($lines)

    Write-Host "Uninstalling sysmon: "
    sysmon.exe -u force
}

Start-Analysis




