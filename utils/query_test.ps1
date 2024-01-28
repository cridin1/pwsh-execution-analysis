# $queryxml= '
# <QueryList> 
#   <Query Id="0" Path="Microsoft-Windows-Sysmon/Operational"> 
#     <Select Path="Microsoft-Windows-Sysmon/Operational"> 
#       *[EventData[Data[@Name="ProcessId"] = 13736]]
#     </Select> 
#   </Query>
# </QueryList>
# '

# $xPath="*[EventData[Data[@Name='ProcessId'] = 2444]]"
# $logname="Microsoft-Windows-Sysmon"

# Get-WinEvent -Provider $logname -FilterXPath $xPath

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


# $logs1 = Get-WinEvent -Path "$pwd\evtx\output1.evtx" | Where-Object {$_.Id -gt 1}
# $logs2 = Get-WinEvent -Path "$pwd\evtx\output2.evtx" | Where-Object {$_.Id -gt 1}
# Write-Host "Logs1: $($logs1.Count)" "Logs2: $($logs2.Count)"

# foreach($event1 in $logs1) {
#     $evt1 = $($event1 | Parse-Event)
#     foreach($event2 in $logs2) {
#         $evt2 = $($event2 | Parse-Event)
#         $evt2.Image
#         Compare-Object -ReferenceObject $evt1 -DifferenceObject $evt2 -Property Image
#         $list = $evt1 | Get-Member -MemberType NoteProperty
#         $properties = ($evt1.properties | Get-Member -MemberType Property)
#         $properties
#         #Write-Host $list.Type
#         #$evt2 | Get-Member -MemberType NoteProperty
#         exit
#     }
# }


# # foreach ($event in $logs1) {
# #     $evt = $event | Parse-Event
# #     #$evt | Get-Member -MemberType NoteProperty
# #     $out = Compare-Object -ReferenceObject $evt -DifferenceObject $logs2 
# # }

# #$maxRecordId = (Get-WinEvent -Provider "Microsoft-Windows-Sysmon" -max 1).RecordID
# $id = 9472
# $XPATH1 = "*[System[EventRecordID > 1] and EventData[Data[@Name='ParentProcessId'] = $id or Data[@Name='ProcessId'] = $id]]"
# $child_id = Get-WinEvent -Path "$pwd\evtx\output4.evtx" -FilterXPath  $XPATH1 | Select-Object -Property @{Name="Process Id";Expression={$_.Properties[3].Value}}
# $ids = $child_id."Process Id"

# # $XPATH2 = "*[EventData[Data[@Name='ProcessId'] = $id]]"
# # $logs = Get-WinEvent -Path "$pwd\evtx\output4.evtx" -FilterXPath  $XPATH2 | Select-Object -Property @{Name="Process Id";Expression={$_.Properties[3].Value}}, @{Name="Parent Process Id";Expression={$_.Properties[4].Value}}, @{Name="Image";Expression={$_.Properties[5].Value}}, @{Name="CommandLine";Expression={$_.Properties[6].Value}}

# #constructing xpath query
# $XPath3 = "*[EventData[ "
# $j = 0
# foreach($id in $ids){
#     if($j -eq 0){
#         $XPath3 += "Data[@Name='ProcessId'] = $id "
#     }
#     else{
#         $XPath3 += " or Data[@Name='ProcessId'] = $id "
#     }
#     $j++
# }
# $XPath3 += "]]"
# Write-Host $XPath3

# $logs = Get-WinEvent -Path "$pwd\evtx\output4.evtx" -FilterXPath  $XPath3 | Select-Object -Property @{Name="Process Id";Expression={$_.Properties[3].Value}}, @{Name="Parent Process Id";Expression={$_.Properties[4].Value}}, @{Name="Image";Expression={$_.Properties[5].Value}}, @{Name="CommandLine";Expression={$_.Properties[6].Value}}
# $logs

#get all properties
$logs = Get-WinEvent -Path "$pwd\evtx\output4.evtx" | Select-Object -Property @{Name="Process Id";Expression={$_.Properties[3].Value}}, @{Name="Image";Expression={$_.Properties[4].Value}}, @{Name="Image";Expression={$_.Properties[5].Value}}, @{Name="CommandLine";Expression={$_.Properties[6].Value}}
$logs | Format-Table -AutoSize
#| Export-CSV ".\SystemEvents.CSV" -NoTypeInformation -Encoding UTF8



