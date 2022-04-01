<#
.SYNOPSIS
This is monthly KRI report automation
.DESCRIPTION
The script 
#>


# here we will get the file and check the double-check the name
#Get-ChildItem -filter *.csv | 
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$csvfile = $dir + '\Syslog-ASA-vpnuser_table.csv'
$resultfile = $dir + '\Report.csv'
#null the output file
out-file $resultfile
$SectionBreak = "`n ---- `n"

#text part of the report
#on Incidents
[int]$INCCount = Read-Host "Number of Incidents "
$INCCountMessage = "Number of Incidents: " + $INCCount
$INCMessage = " "
IF ($INCCount -ne 0)
{
    [string]$INCMessage = Read-Host "Details?"
}
Add-Content $resultfile $INCCountMessage
$INCMessage = "Comment:" + $INCMessage
Add-Content $resultfile $INCMessage
Add-Content $resultfile $SectionBreak

#on spare trader machine
[int]$PCCount = Read-Host "Spare Trader Machines "
$PCCountMessage = "Spare Trader Machines: " + $PCCount
$PCMessage = " "
IF ($PCCount -eq 0)
{
    [string]$PCMessage = Read-Host "Details?"
}
Add-Content $resultfile $PCCountMessage
$PCMessage = "Comment:" + $PCMessage
Add-Content $resultfile $PCMessage
Add-Content $resultfile $SectionBreak

#on spare Cisco phones
[int]$IPPhonesCount = Read-Host "Spare Cisco Phones "
$IPPhonesCountMessage = "Spare Cisco Phones: " + $IPPhonesCount
$IPPhonesMessage = " "
IF ($IPPhonesCount -eq 0)
{
    [string]$IPPhonesMessage = Read-Host "Details?"
}
Add-Content $resultfile $IPPhonesCountMessage
$IPPhonesMessage = "Comment:" + $IPPhonesMessage
Add-Content $resultfile $IPPhonesMessage
Add-Content $resultfile $SectionBreak

#on spare trader dealerboards
[int]$DealerBCount = Read-Host "Spare Trader Dealerboards "
$DealerBCountMessage = "Spare Trader Dealerboards: " + $DealerBCount
$DealerBMessage = " "
IF ($DealerBCount -eq 0)
{
    [string]$DealerBMessage = Read-Host "Details?"
}
Add-Content $resultfile $DealerBCountMessage
$PCMessage = "Comment:" + $DealerBMessage
Add-Content $resultfile $DealerBMessage
Add-Content $resultfile $SectionBreak



Add-Content $resultfile "Number of Users who logged in for more than 3 consecutive days"
#Extract the list of names and display it
$Users =  Import-csv $csvfile| Sort-Object -Property 'user.raw: Ascending' -Unique | Select-Object -ExpandProperty 'user.raw: Ascending'
$Users
$PreviousDate = Get-Date
[int]$Eventid = 1

$Users.ForEach(
{
    $Person = $_
    #$Person
    [int]$Counter = 1
    #$File |Where-Object -FilterScript {$_.'user.raw: Ascending' -eq "$Person"} | Out-file "$Person.txt"
    $UserEntries = Import-csv $csvfile |Where-Object -FilterScript {$_.'user.raw: Ascending' -eq "$Person"}
    
    #Dates array
    $Dates = $UserEntries | Select-Object -ExpandProperty '@timestamp: Ascending' -Unique
    $Dates = $Dates -replace "(\d)(th|nd|st|rd)",'$1'
    $Dates = [Datetime[]]$Dates
    $Dates = [Datetime[]]$Dates.Date
    $Dates = $Dates | Get-Unique
    #$Dates
    #the block down does not work as intended
    ForEach ($Date in $Dates)
        {
        [datetime]$CurrentDate = $Date
        $CurrentDate
        IF ($CurrentDate -eq [datetime]$PreviousDate.AddDays(+1))
            {
                $Counter = $Counter + 1
                $EndDate = $Date
            }
            ELSE
            {
                IF ($Counter -ge 3)
                    {
                        $StartDate = $EndDate.AddDays(-$Counter+1)
                        [string]$Message = "EventID: " + [string]$Eventid + " Person: " + [string]$Person + " Number of days: " + [string]$Counter + " Start Date: " + [string]$StartDate + " End Date: " + [string]$EndDate
                        Out-File -InputObject $Message -FilePath $ResultFile -Append
                        $Eventid = $Eventid +1
                        #$Counter
                    }
                $Counter=1
            }
        [datetime]$PreviousDate = $CurrentDate
        }
    #$Counter
    IF ($Counter -ge 3)
        {
            $StartDate = $EndDate.AddDays(-$Counter+1)
            [string]$Message = "EventID: " + [string]$Eventid + " Person: " + [string]$Person + " Number of days: " + [string]$Counter + " Start Date: " + [string]$StartDate + " End Date: " + [string]$EndDate
            Out-File -InputObject $Message -FilePath $ResultFile -Append
            $Eventid = $Eventid +1
            #$Counter
         }
}
)
Add-Content $resultfile $SectionBreak

# find session longer than one hour and more than 10Mbytes transmitted
[int]$SessionThreshold = 10485760
#set custom table format
$SessionsTableFormat = @{Expression={$_.'@timestamp: Ascending'};Label="Time"}, @{Expression={$_.'user.raw: Ascending'};Label="User"}, @{Expression={$_.'duration.raw: Descending'};Label="Duration"}, @{Expression={$_.'Max TransmitBytes'};Label="Transmitted"} 
$Sessions = Import-csv $csvfile | Where-Object {[int]$_.'Max TransmitBytes' -gt $SessionThreshold -and $_.'duration.raw: Descending'.Startswith('0h:')}
$SessionCount = $($Sessions | Measure-Object).Count
Add-Content $resultfile "`n`n`n"
$SessionsMessage =  "Number of connections with data transferred over 10MB with connection time lasting less than 1 hour: " + $SessionCount 
Add-Content $resultfile $SessionsMessage
$Sessions | Format-Table $SessionsTableFormat -AutoSize| Out-File $resultfile -Append