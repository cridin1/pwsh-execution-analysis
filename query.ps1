$queryxml= '
<QueryList> 
  <Query Id="0" Path="Microsoft-Windows-Sysmon/Operational"> 
    <Select Path="Microsoft-Windows-Sysmon/Operational"> 
      *[EventData[Data[@Name="ProcessId"] = 13736]]
    </Select> 
  </Query>
</QueryList>
'

$xPath="*[EventData[Data[@Name='ProcessId'] = 2444]]"
$logname="Microsoft-Windows-Sysmon"

Get-WinEvent -Provider $logname -FilterXPath $xPath