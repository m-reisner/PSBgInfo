##Requires -Version 7.0
##Requires -RunAsAdministrator

###
# Dieses Script sammelt Information zum Client und stellt diese im Objekt $clientdata zur Verfügung.
# Version 1.0 Stand 17.01.2025 (C) 2025 Martin Reisner
###
# Folgende Information stehen zur Verfügung:
# Hostname
# Domain
# Bootzeit
# Logonserver
# Benutzername
# Netzwerk Interface Index
# Netzwerk Interface Name
# Netzwerk Interface IP-Adresse
# Netzwerk Interface Mac-Adresse
# Netzwerk Interface Errors
# Festplatte Dateisystemtype
# Festplatte Größe
# Festplatte freier Speicher
# Hausinterner Informationstext
# Alermmeldungen
# Bildschirm- und ScreenInformationen
# Betriebssysteminformationen
# Netzwerk CDP Informationen
###
# Compliance-Check
# Es wird gerpüft, ob mehr als 10% der Festplatte verfügbar sind. 

if (-not ('System.Drawing' -as [type])) { Add-Type -AssemblyName System.Drawing }
if (-not ('System.Windows.Forms' -as [type])) { Add-Type -AssemblyName System.Windows.Forms }

###
# Get Basic Computerinformations
#
Write-Verbose -Message "Get basic client informations."
$clientdata = New-Object -TypeName PSObject
$clientdata | Add-Member -Name 'AppPath' -MemberType Noteproperty -Value $PSScriptRoot
$clientdata | Add-Member -Name 'Hostname' -MemberType Noteproperty -Value $env:COMPUTERNAME
$clientdata | Add-Member -Name 'Domain' -MemberType Noteproperty -Value $env:USERDNSDOMAIN
    $LastBootUpTime = ($(Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object LastBootUpTime).LastBootUpTime).ToString("dd.MM.yyyy HH:mm")
$clientdata | Add-Member -Name 'Boottime' -MemberType Noteproperty -Value "$($LastBootUpTime) Uhr"
$clientdata | Add-Member -Name 'Logonserver' -MemberType Noteproperty -Value ($env:LOGONSERVER).Replace("\\","")
$clientdata | Add-Member -Name 'Username' -MemberType Noteproperty -Value $env:USERNAME
Write-Verbose -Message "Get networking informations."
    $ifcfg = Get-NetIPConfiguration -InterfaceAlias Ethernet
$clientdata | Add-Member -Name 'IPIfIndex' -MemberType Noteproperty -Value ($ifcfg).InterfaceIndex
$clientdata | Add-Member -Name 'IPIfAlias' -MemberType Noteproperty -Value ($ifcfg).InterfaceAlias
$clientdata | Add-Member -Name 'IPAddress' -MemberType Noteproperty -Value ($ifcfg).IPv4Address[0].IPAddress
    $macaddr = (((Get-NetAdapter -InterfaceIndex ((Get-NetIPConfiguration -InterfaceAlias Ethernet).InterfaceIndex)).MacAddress).Replace(":","").Replace(".","").Replace("-","")).ToLower()
$clientdata | Add-Member -Name 'MacAddress' -MemberType Noteproperty -Value $macaddr
    $iferr = Get-NetAdapterStatistics -Name Ethernet | Select-Object OutboundDiscardedPackets, OutboundPacketErrors, ReceivedDiscardedPackets, ReceivedPacketErrors
$clientdata | Add-Member -Name 'NetErrors' -MemberType Noteproperty -Value "od $($iferr.OutboundDiscardedPackets) oe $($iferr.OutboundPacketErrors) id $($iferr.ReceivedDiscardedPackets) ie $($iferr.ReceivedPacketErrors)"
    $hddvol = Get-CimInstance -Query "SELECT Size,FreeSpace,FileSystem FROM Win32_LogicalDisk WHERE DeviceID LIKE 'C%'" | Select-Object -Property Size, FreeSpace,FileSystem
Write-Verbose -Message "Get Harddrive informations."
$clientdata | Add-Member -Name 'HDDType' -MemberType Noteproperty -Value "C: [$(($hddvol).FileSystem)]"
    $hddsize = $([Math]::Round((($hddvol).Size / 1GB),2))
    $hddfree = $([Math]::Round((($hddvol).FreeSpace /1GB),2))
    $hddfree = 23
$clientdata | Add-Member -Name 'HDDSize' -MemberType Noteproperty -Value "$($hddsize) GB"
$clientdata | Add-Member -Name 'HDDFree' -MemberType Noteproperty -Value "$($hddfree) GB"
    $infotext = "Unterstützen Sie die Datensicherheit:`nMelden Sie sich bei Nichtbenutzung ab!`n`nVermeiden Sie Datenverluste:`nSpeichern Sie nur auf`nNetzwerklaufwerke!"
$clientdata | Add-Member -Name 'Infotext' -MemberType Noteproperty -Value $infotext
    if ($hddfree -le ($hddsize /10)) {
        $alerttext = "Der Client hat wenig freien Platz`nauf seiner Festplatte!`n`nBitte kontaktieren Sie die`nIT Hotline unter der Klappe 14700"
        $clientdata | Add-Member -Name 'Alerttext' -MemberType Noteproperty -Value $alerttext
    }

Write-Verbose -Message "Get screen- and display informations."
###
# Get Display- and Screen-Informations
$srcns = [System.Windows.Forms.Screen]::AllScreens
$c=0
foreach ( $screen in $srcns ) {
    $screenbound = $screen.Bounds
    $scrobject = New-Object -TypeName PSObject
    $scrobject | Add-Member -Name 'DeviceName' -MemberType Noteproperty -Value ($screen.DeviceName).Replace("\\.\","")
    $scrobject | Add-Member -Name 'Width' -MemberType Noteproperty -Value $screenbound.Width
    $scrobject | Add-Member -Name 'Height' -MemberType Noteproperty -Value $screenbound.Height
    $scrobject | Add-Member -Name 'BitsPerPixel' -MemberType Noteproperty -Value $screen.BitsPerPixel
    $scrobject | Add-Member -Name 'Primary' -MemberType Noteproperty -Value $screen.Primary
    $scrobject | Add-Member -Name 'Bounds' -MemberType Noteproperty -Value $screen.Bounds
    $scrobject | Add-Member -Name 'WorkingArea' -MemberType Noteproperty -Value $screen.WorkingArea
    $clientdata | Add-Member -Name "Screen$($c)" -MemberType Noteproperty -Value $scrobject
    $c++
}
$clientdata | Add-Member -Name "Screens" -MemberType Noteproperty -Value ($c++)

Write-Verbose -Message "Get Operatingsysem informations."
###
# Get OS Systeminformationen
#
$instance = (Get-CimInstance Win32_OperatingSystem)
$osobject = New-Object -TypeName PSObject
$osobject | Add-Member -Name "Name" -MemberType Noteproperty -Value $instance.Caption
$osobject | Add-Member -Name "InstallDate" -MemberType Noteproperty -Value "$($($instance.InstallDate).ToString("dd.MM.yyyy HH:mm")) Uhr"
$osobject | Add-Member -Name "Version" -MemberType Noteproperty -Value $instance.Version
$osobject | Add-Member -Name "MUILanguages" -MemberType Noteproperty -Value $instance.MUILanguages
$osobject | Add-Member -Name "OSArchitecture" -MemberType Noteproperty -Value $instance.OSArchitecture
$osobject | Add-Member -Name "RegisteredUser" -MemberType Noteproperty -Value $instance.RegisteredUser
$osobject | Add-Member -Name "SerialNumber" -MemberType Noteproperty -Value $instance.SerialNumber
$clientdata | Add-Member -Name "OS" -MemberType Noteproperty -Value $osobject

Write-Verbose -Message "Get network cdp informations."
###
# Get Network CDP Informations
# Inspired by https://www.tenaci.us/remotely-get-cdp-neighbor
#
If (Test-Path ".\temp.etl") { Remove-Item ".\temp.etl" }
$t = New-Item -Path ".\temp.etl" -ItemType File
$a = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceType -eq 6 } | Select-Object -First 1 -Expand Name
$ns = Get-NeteventSession -Name CDP 2>$Null
If ($ns) { 
    If ($ns.SessionStatus -eq "Running") { Stop-NetEventSession -Name CDP }
    Remove-NetEventSession -Name CDP
}
$s = New-NetEventSession -Name CDP -LocalFilepath $t -CaptureMode SaveToFile
$ma = "01-00-0c-cc-cc-cc"
$cl = 61
Add-NetEventPacketCaptureProvider -SessionName $s.Name -LinkLayerAddress $ma -TruncationLength 1024 -CaptureType BothPhysicalAndSwitch | Out-Null
Add-NetEventNetworkAdapter -Name $a -PromiscuousMode $True | Out-Null
Start-NetEventSession -Name $s.Name
$end = (Get-Date).AddSeconds($cl)
While ($end -gt (Get-Date)) {
    $left = $end.Subtract((Get-Date)).TotalSeconds
    $perc = ($cl - $left) / $cl * 100
    Write-Progress -Activity "CDP Packet Capture" -Status "Capturing Packets..." -SecondsRemaining $left -PercentComplete $perc
    Start-Sleep 1
}
Stop-NetEventSession -Name $s.Name
$log = Get-Winevent -Path $t -Oldest | Where-Object { $_.Id -eq 1001 -and [UInt16]0x2000 -eq [BitConverter]::ToUInt16($_.Properties[3].Value[21..20], 0) } | Select-Object -Last 1 -Expand Properties
Remove-NetEventSession -Name $s.Name
Start-Sleep -Seconds 2
Remove-Item -Path $t
If ($log) { $packet = $log[3].Value }
$offset = 26
$netobject = New-Object -TypeName PSObject
While ($offset -lt ($packet.Length -4)) {
    $type = [BitConverter]::ToUInt16($packet[($offset + 1)..$offset], 0)
    $len = [BitConverter]::ToUInt16($packet[($offset + 3)..($offset + 2)], 0)
    Switch ($type) {
        1	{ $netobject | Add-Member -Name "SwitchHostname" -MemberType Noteproperty -Value ([System.Text.Encoding]::ASCII.GetString($packet[($offset + 4)..($offset + $len)])) }
        2	{ $netobject | Add-Member -Name "SwitchIPAddress" -MemberType Noteproperty -Value ([System.Net.IPAddress][byte[]]$packet[($offset + 13)..($offset + 16)]).IPAddressToString }
        3	{ $netobject | Add-Member -Name "SwitchPort" -MemberType Noteproperty -Value ([System.Text.Encoding]::ASCII.GetString($packet[($offset + 4)..($offset + $len)])) }
        6	{ $netobject | Add-Member -Name "SwitchType" -MemberType Noteproperty -Value ([System.Text.Encoding]::ASCII.GetString($packet[($offset + 4)..($offset + $len)])) }
        10	{ $netobject | Add-Member -Name "SwitchVLAN" -MemberType Noteproperty -Value ([BitConverter]::ToUInt16($packet[($offset + 5)..($offset + 4)], 0)) }
    }
    $offset = $offset + $len
}

$clientdata | Add-Member -Name "Network" -MemberType Noteproperty -Value $netobject

Write-Verbose -Message "Clear memmory."
###
# Remove /Clear all variables except $clientdata and importent Powershell Variables
#
Remove-Variable -Scope Script -Name * -Exclude clientdata,PWD,*Preference,PS* -Force -ErrorAction SilentlyContinue