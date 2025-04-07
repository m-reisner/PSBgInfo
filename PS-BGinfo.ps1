##Requires -Version 7.0
##Requires -RunAsAdministrator

$VerbosePreference = "SilentlyContinue" # no messages
#$VerbosePreference = "Continue"         # verbose messages

Clear-Host

if (-not ('System.Drawing' -as [type])) { Add-Type -AssemblyName System.Drawing }
if (-not ('System.Windows.Forms' -as [type])) { Add-Type -AssemblyName System.Windows.Forms }

# ermittle Client Informationen.
."$($PSScriptRoot)\get-clientdata.inc.ps1"

$DoPreview = $true

$filename = "foo.png"
# erstellen eines neuen Bildes.
$BGimg = new-object System.Drawing.Bitmap($($clientdata.Screen0).Width,$($clientdata.Screen0).Height)

# wähle basic Front- and Backgroundcolor.
$font = new-object System.Drawing.Font "Segoe UI",10
$Alpha = 255
$Red = 0
$Green = 78
$Blue = 152
$colorForBrush = [System.Drawing.Color]::FromArgb($Alpha, $Red, $Green, $Blue)
$brushBG = [System.Drawing.SolidBrush]::new($colorForBrush)

$graphics = [System.Drawing.Graphics]::FromImage($BGimg)
$graphics.FillRectangle($brushBg,0,0,$BGimg.Width,$BGimg.Height)

# Hintergrund und Rahmen
$Alpha = 25
$Red = 255
$Green = 255
$Blue = 255
$colorForBrush = [System.Drawing.Color]::FromArgb($Alpha, $Red, $Green, $Blue)
$brushBG = [System.Drawing.SolidBrush]::new($colorForBrush)
$graphics.FillRectangle($brushBg,($($clientdata.Screen0).Width - 410),10,400,890)

$Alpha = 125
$Red = 255
$Green = 255
$Blue = 255
$colorForBrush = [System.Drawing.Color]::FromArgb($Alpha, $Red, $Green, $Blue)
$brushBG = [System.Drawing.SolidBrush]::new($colorForBrush)
$graphics.DrawRectangle($brushBg,($($clientdata.Screen0).Width - 410),10,400,890)

# Icons einfügen
$myicons = @(
    [PSCustomObject]@{imagefile="\res\logo.png";        PosX=($($clientdata.Screen0).Width - 400); PosY=20;  width=385; height=100},
    [PSCustomObject]@{imagefile="\res\computer.png";    PosX=($($clientdata.Screen0).Width - 400); PosY=150; width=32;  height=32},
    [PSCustomObject]@{imagefile="\res\server.png";      PosX=($($clientdata.Screen0).Width - 400); PosY=220; width=32;  height=32},
    [PSCustomObject]@{imagefile="\res\windows.png";     PosX=($($clientdata.Screen0).Width - 400); PosY=300; width=32;  height=32},
    [PSCustomObject]@{imagefile="\res\network.png";     PosX=($($clientdata.Screen0).Width - 400); PosY=390; width=32;  height=32},
    [PSCustomObject]@{imagefile="\res\router.png";      PosX=($($clientdata.Screen0).Width - 400); PosY=485; width=32;  height=32},
    [PSCustomObject]@{imagefile="\res\storage.png";     PosX=($($clientdata.Screen0).Width - 400); PosY=590; width=32;  height=32},
    [PSCustomObject]@{imagefile="\res\information.png"; PosX=($($clientdata.Screen0).Width - 400); PosY=700; width=32;  height=32}
)
foreach ( $icon in $myicons ) {
    # Lade Bild und mache ein overlay daraus
    $OverlaySrcPath = "$($clientdata.AppPath)$($icon.imagefile)"
    $OverlaysrcImg = [System.Drawing.Image]::FromFile($OverlaySrcPath)
    $graphics.DrawImage($OverlaysrcImg, $($icon.PosX), $($icon.PosY), $($icon.width), $($icon.height))
    $OverlaysrcImg.Dispose()
}

# Farben festlegen
$ColorYellow = [System.Drawing.Brushes]::Yellow
$ColorWhite = [System.Drawing.Brushes]::White
$ColorMagenta = [System.Drawing.Brushes]::Magenta
$font = new-object System.Drawing.Font "Segoe UI",12

# Pen für Linien festlegen
$Alpha = 125
$Red = 255
$Green = 255
$Blue = 255
$colorForBrush = [System.Drawing.Color]::FromArgb($Alpha, $Red, $Green, $Blue)
$Pen = New-Object System.Drawing.Pen $colorForBrush, 2

# Daten einfügen
$graphics.DrawString("Hostname:       `t$($clientdata.Hostname)",               $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 140)
$graphics.DrawString("Domain:         `t$($clientdata.Domain)",                 $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 160)
$graphics.DrawString("Boottime:       `t$($clientdata.Boottime)",               $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 180)
$graphics.DrawString("",                                                        $font,$ColorWhite,  ($($clientdata.Screen0).Width - 400), 200)
$graphics.DrawString("Logonserver:    `t$($clientdata.Logonserver)",            $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 220)
$graphics.DrawString("Username:       `t$($clientdata.Username)",               $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 240)
$graphics.DrawString("",                                                        $font,$ColorWhite,  ($($clientdata.Screen0).Width - 400), 260)
$Betriebssystem = $($clientdata.OS.Name) -replace "Microsoft ", ""
$graphics.DrawString("Windows:        `t$($Betriebssystem)",                    $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 280)
$graphics.DrawString("Version:        `t$($clientdata.OS.Version)",             $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 300)
$graphics.DrawString("Installiert:    `t$($clientdata.OS.InstallDate)",         $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 320)
$graphics.DrawString("",                                                        $font,$ColorWhite,  ($($clientdata.Screen0).Width - 400), 340)

$graphics.DrawString("Interfaceindex: `t$($clientdata.IPIfIndex)",              $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 360)
$graphics.DrawString("Interfacealias: `t$($clientdata.IPIfAlias)",              $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 380)
$graphics.DrawString("IPv4-Adresse:   `t$($clientdata.IPAddress)",              $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 400)
$graphics.DrawString("Mac-Adresse:    `t$($clientdata.MacAddress)",             $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 420)
$graphics.DrawString("",                                                        $font,$ColorWhite,  ($($clientdata.Screen0).Width - 400), 440)
$hostnameswitch = $($clientdata.Network.SwitchHostname)
$hostnameswitch = $hostnameswitch -replace "REMOVE DOMAIN", ""
$graphics.DrawString("Hostname:       `t$hostnameswitch",                       $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 460)
$graphics.DrawString("SW-IP:          `t$($clientdata.Network.SwitchIPAddress)",$font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 480)
$graphics.DrawString("VLAN:           `t$($clientdata.Network.SwitchVLAN)",     $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 500)
$graphics.DrawString("Port:           `t$($clientdata.Network.SwitchPort)",     $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 520)
$graphics.DrawString("Switch:         `t$($clientdata.Network.SwitchType)",     $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 540)
$graphics.DrawString("",                                                        $font,$ColorWhite,  ($($clientdata.Screen0).Width - 400), 560)
$graphics.DrawString("HDD-Type:       `t$($clientdata.HDDType)",                $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 580)
$graphics.DrawString("HDD-Size:       `t$($clientdata.HDDSize)",                $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 600)
$graphics.DrawString("HDD-Free:       `t$($clientdata.HDDFree)",                $font,$ColorWhite,  ($($clientdata.Screen0).Width - 360), 620)
$graphics.DrawString("",                                                        $font,$ColorWhite,  ($($clientdata.Screen0).Width - 400), 640)
$graphics.DrawString("$($clientdata.Infotext)",                                 $font,$ColorYellow, ($($clientdata.Screen0).Width - 360), 650)

if ($hddfree -le ($hddsize /10)) {
    $graphics.DrawString("",         $font,$ColorWhite,  ($($clientdata.Screen0).Width - 400), 780)
    $OverlaySrcPath = "$($clientdata.AppPath)\res\alert.png"
    $OverlaysrcImg = [System.Drawing.Image]::FromFile($OverlaySrcPath)
    $graphics.DrawImage($OverlaysrcImg,($($clientdata.Screen0).Width - 400), 825, 32, 32)
    $OverlaysrcImg.Dispose()
    $graphics.DrawString("$($clientdata.Alerttext)",$font,$ColorMagenta, ($($clientdata.Screen0).Width - 360), 785)
}

# Trennlinien ziehen
$graphics.DrawLine($Pen, ($($clientdata.Screen0).Width - 400), 210, ($($clientdata.Screen0).Width - 15), 210)
$graphics.DrawLine($Pen, ($($clientdata.Screen0).Width - 400), 270, ($($clientdata.Screen0).Width - 15), 270)
$graphics.DrawLine($Pen, ($($clientdata.Screen0).Width - 400), 350, ($($clientdata.Screen0).Width - 15), 350)
$graphics.DrawLine($Pen, ($($clientdata.Screen0).Width - 400), 450, ($($clientdata.Screen0).Width - 15), 450)
$graphics.DrawLine($Pen, ($($clientdata.Screen0).Width - 400), 570, ($($clientdata.Screen0).Width - 15), 570)
$graphics.DrawLine($Pen, ($($clientdata.Screen0).Width - 400), 650, ($($clientdata.Screen0).Width - 15), 650)
$graphics.DrawLine($Pen, ($($clientdata.Screen0).Width - 400), 780, ($($clientdata.Screen0).Width - 15), 780)

# Speicher freigeben, fertiges Bild speichern und Bild als Vorschau öffnen.
$graphics.Dispose()
$BGimg.Save("$($env:TEMP)\$filename")
$BGimg.Save("$($PSScriptRoot)\$filename")
$BGimg.Dispose()

if ($DoPreview -eq $true) {
    Start-Process "$($env:TEMP)\$filename"
} else {
    #Set Background Image
    $setwallpapersrc=@"
using System.Runtime.InteropServices;

public class Wallpaper {
public const int SetDesktopWallpaper = 20;
public const int UpdateIniFile = 0x01;
public const int SendWinIniChange = 0x02;
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
public static void SetWallpaper(string path) {
SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
}
}
"@
    Add-Type -TypeDefinition $setwallpapersrc
    [Wallpaper]::SetWallpaper("$($env:TEMP)\$filename")
}

Remove-Variable -Scope Script -Name * -Exclude PWD,*Preference,PS* -Force -ErrorAction SilentlyContinue