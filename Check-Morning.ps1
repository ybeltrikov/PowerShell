<#
.SYNOPSIS
This is morning check automation

.DESCRIPTION
The script performs morning infrastructure check and produces email report
#>

function Get-MorningCheckUserInput {
    <#
    .SYNOPSIS
    This function asks user to confirm the service status and return $True if the service is ok and $False otherwise 
    #>
    Param(
        [Parameter(Mandatory=$True)]
        [string]$ServiceChecked
    )
    Do {
        try {
            [char]$ServiceStatus = Read-Host "Is $ServiceChecked ok? [y/n]"    
        }
        catch {
            Write-host `t "Please enter Yes[y] or No[n]" -ForegroundColor Red
        }
        
    } while (!(($ServiceStatus -eq "y") -or ($ServiceStatus -eq "n")))

    $ServiceOK = $false
    $ServiceOK = ($ServiceStatus -eq 'y')
    $ServiceOK

} #function

function Get-KAVStatus {
    <#
    .SYNOPSIS
    This checks KAV servers status by launching directly SQL selects to the Kaspersky Security Centre database
    #>
    Param(
        [Parameter(Mandatory=$True)]
        [string]$KAVServer
    )
    #$KAVStatus = $false
    $InfectedItemsSQL = "SELECT * FROM v_akpub_infected_item;"
    $HostsStatusSQL = "SELECT * FROM v_akpub_host_status_ps;"
    $DatabaseName = "KAV"
    
    $KAVInfectedIems = Invoke-Sqlcmd -Query $InfectedItemsSQL -ServerInstance $KAVServer -Database $DatabaseName
    If ($KAVInfectedIems -ne $null) {
        Write-Host `t "Infected items not null. Please check $KAVServer manually" -ForegroundColor Red
    }
    else {
        Write-Host `t "$KAVServer no infected items"  -ForegroundColor Green
    }

    $KAVHostStatus = Invoke-Sqlcmd -Query $HostsStatusSQL -ServerInstance $KAVServer -Database $DatabaseName
    $KAVHoststoCheck = $KAVHostStatus | Where-Object nStatus -NE 0
    #$StringWithHosts = ""
    If ($KAVHoststoCheck -ne $null){
        Write-Host `t "KAV Hosts to check: " -ForegroundColor Red
        foreach ($hostToCheck in $KAVHoststoCheck) {
            #$StringWithHosts = $StringWithHosts + ($hostToCheck.itemarray -join ",")
            Write-Host `t $hostToCheck.itemarray -ForegroundColor Red
        } #foreach
    }
    else {
        Write-Host `t "All $KAVServer hosts are fine" -ForegroundColor Green
    }
   

    Get-MorningCheckUserInput ($KAVServer)


} #function

function Check-OKIstatus {
    <#
    .SYNOPSIS
    This opens OKI printer web page, parces for errors and displays warnings and errors
    #>
    Param(
        [Parameter(Mandatory=$True)]
        [string]$OKIURL
    )
    #warning and error messages which are checked by the function
    #Drum Life Warning
    #Paper Out Warning
    #Document Jam 
    #Paper Input Jam 
    #Toner Low for 
    #Toner Out for 
    #Toner Sensor Error for
    #Cover Open for 
    #Paper Cassette Open 
    #Duplex Unit Error 
    $WebResult = Invoke-WebRequest $OKIURL
    switch ($WebResult.Content)
    {
        {$_ -match "Drum Life Warning"} {Write-Host `t "OKI prnter: Drum Life Warning" -ForegroundColor Red
            }
        {$_ -match "Paper Out Warning"}{Write-Host `t "OKI prnter: Out of Paper" -ForegroundColor Red
            }
        {$_ -match "Document Jam"}{Write-Host `t "OKI prnter: Document Jam" -ForegroundColor Red
            }
        {$_ -match "Paper Input Jam"}{Write-Host `t "OKI prnter: Paper Input Jam" -ForegroundColor Red
            }
        {$_ -match "Toner Low for"}{Write-Host `t "OKI prnter: Low Toner" -ForegroundColor Red
            }
        {$_ -match "Toner Out for"}{Write-Host `t "OKI prnter: Out of Toner" -ForegroundColor Red
            }
        {$_ -match "Toner Sensor Error for"}{Write-Host `t "OKI prnter: Toner Sensor Error" -ForegroundColor Red
            }
        {$_ -match "Cover Open for"}{Write-Host `t "OKI prnter: Cover Open" -ForegroundColor Red
            }
        {$_ -match "Paper Cassette Open"}{Write-Host `t "OKI prnter: paper cassette open" -ForegroundColor Red
            }
        {$_ -match "Duplex Unit Error"}{Write-Host `t "OKI prnter: Duplex Unit Error" -ForegroundColor Red
            }
            default {Write-Host `t "OKI printer is fine" -ForegroundColor Green
        }
        
    } #switch
    

} #function
function Get-Kyocerastatus {
    <#
    .SYNOPSIS
    This opens Kyocera printer web page and parces for errors
    #>
    Param(
        [Parameter(Mandatory=$True)]
        [string]$KyoceraURL
    )


} #function


#Hash table for all status reports
$StatusTable = [ordered]@{'Mail' = 'not OK'
'Phone Service Check' = 'not OK'
'File Server' = 'not OK'
'Printers' = 'not OK'
'Meeting Room' = 'not OK'
'Redbox' = 'not OK'
'Derivatives DB' = 'not OK'
'KAV' = 'not OK'
'USA KAV' = 'not OK'}

$EmailRecipient = "morning-check@yahoo.co.uk"
$Emailbody = "<html>
<style>
TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
TD{border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
"

$EmailSubject = "London morning check"

#get the current date and calcualte yesterday 
$Today = (Get-Date).Date
$Yesterday = $Today.adddays(-1)

#Check Redbox
$RedboxDate = (Get-ItemProperty \\fileshare\Flstore\Redbox\R3258\SizeInfo.dat).LastWriteTime.Date
$RedboxOk = ($RedboxDate -eq $Today) -or ($RedboxDate -eq $Yesterday)
If ($RedboxOk) {
    $StatusTable.Redbox = 'OK'
}
switch ($RedboxOk) {
    $True {$RedboxTextColour = "Green"}
    $false {$RedboxTextColour="Red"}
}
Write-Host `t "Redbox OK: $RedboxOk" -ForegroundColor $RedboxTextColour

#Check MySQL Dump
$MySQLDate = (Get-ChildItem -path "\\fileshare\flstore\I.T\SQL Dump" | Where-Object -FilterScript {$_.Name -like 'Dump_mysql*'} | Sort-Object LastWriteTime -Descending | select-object -First 1).LastWriteTime.Date
$MySQLOK = ($MySQLDate -eq $Today)
If ($MySQLOK) {
    $StatusTable."Derivatives DB" = 'OK'
}
switch ($MySQLOK) {
    $True {$MySQLTextColour = "Green"}
    $false {$MySQLTextColour="Red"}
}

Write-Host `t "MySQL OK: $MySQLOK" -ForegroundColor $MySQLTextColour `n`n

#Confirm Mail
$MailOK = Get-MorningCheckUserInput ("Mail")
If ($MailOK) {
    $StatusTable."Mail" = 'OK'
}

#Confirm Phones
$PhoneOK = Get-MorningCheckUserInput ("Phones")
If ($PhoneOK) {
    $StatusTable."Phone Service Check" = 'OK'
}

#Confirm FS
if ((Get-PSDrive I -ErrorAction SilentlyContinue) -and (Get-PSDrive J -ErrorAction SilentlyContinue) -and (Get-PSDrive K -ErrorAction SilentlyContinue) -and (Get-PSDrive R -ErrorAction SilentlyContinue)) 
{
    Write-Host `t "All the network drives are fine" -ForegroundColor Green
} else {
    Write-Host `t "One of the network drives is missing. Please check" -ForegroundColor Red
}

$FSOK = Get-MorningCheckUserInput ("FS")
If ($FSOK) {
    $StatusTable."File Server" = 'OK'
}


#Confirm Printers

Check-OKIstatus("http://10.30.30.30/status.htm")

$urlKyocera = "https://10.40.40.40/"
Write-Host `t "Check Kyocera manually" -ForegroundColor Yellow
Start-Process "chrome.exe" $urlKyocera

$PrintOK = Get-MorningCheckUserInput ("Printers")
If ($PrintOK) {
    $StatusTable."Printers" = 'OK'
}

#Confirm KAV
$KAVOK = Get-KAVStatus ("kav1.corpdomain.local")
If ($KAVOK) {
    $StatusTable."KAV" = 'OK'
}

#Confirm KAV USA
#$KAVUSAOK = Get-MorningCheckUserInput ("KAV USA")
#If ($KAVUSAOK) {
#    $StatusTable."USA KAV" = 'OK'
#}
$KAVUSAOK= Get-KAVStatus ("kav2.corpdomain.local")
If ($KAVUSAOK) {
    $StatusTable."USA KAV" = 'OK'
}

#Ping video codecs in the meeting rooms
$ConnectionroomOne = Test-Connection -ComputerName 10.10.10.10 -Quiet -Count 3
$ConnectionroomTwo = Test-Connection -ComputerName 10.20.20.20 -Quiet -Count 3

switch ($ConnectionroomOne) {
    $True {$roomOneTextColour = "Green"}
    $false {$roomOneTextColour="Red"}
}
switch ($ConnectionroomTwo) {
    $True {$roomTwoTextColour = "Green"}
    $false {$roomTwoTextColour="Red"}
}

Write-Host `t "roomOne OK: $ConnectionroomOne" -ForegroundColor $roomOneTextColour
Write-Host `t "MySQL OK: $ConnectionroomTwo" -ForegroundColor $roomTwoTextColour

#Confirm Meetingroom
$MeetingOK = Get-MorningCheckUserInput ("Meeting Room")
If ($MeetingOK) {
    $StatusTable."Meeting Room" = 'OK'
}

#Display status
<#
Write-Host "`n`nStatus summary"
Write-Host "Mail OK: $MailOK"
Write-Host "Phones OK: $PhoneOK"
Write-Host "File server OK: $FSOK"
Write-Host "Printers OK: $PrintOK"
Write-Host "Meeting room OK: $MeetingOK"
Write-Host "Redbox OK: $RedboxOK"
Write-Host "MySQL OK: $MySQLOK"
Write-Host "KAV OK: $KAVOK"
Write-Host "KAV USA OK: $KAVUSAOK"
#>

#Compose the status report email
$Emailbody = $Emailbody + ($StatusTable.GetEnumerator() | Select-Object Name,Value | ConvertTo-Html -Fragment )

$FindString = "<td>OK</td>"
$ReplaceString = "<td style=`"width: 65px; background-color: green;`">OK</td>"
$Emailbody = $Emailbody -replace $FindString, $ReplaceString

$FindString = "<td>not OK</td>"
$ReplaceString = "<td style=`"width: 65px; background-color: red;`">not OK</td>"
$Emailbody = $Emailbody -replace $FindString, $ReplaceString
$Emailbody = $Emailbody + "</html>"

$Outlook = New-Object -comObject Outlook.Application
$reportemail = $Outlook.CreateItem(0) 
$reportemail.Recipients.Add($EmailRecipient) | Out-Null
$reportemail.Subject = $EmailSubject

$reportemail.HTMLBody = $Emailbody

$reportemail.Display($True)