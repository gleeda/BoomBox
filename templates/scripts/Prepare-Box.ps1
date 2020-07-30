# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

$ErrorActionPreference = "Stop"

# Network Changes
Write-host 'Setting network connection type to Private..'
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Stop Windows Update
Write-Host "Disabling Windows Updates.."
Set-Service wuauserv -StartupType Disabled
Stop-Service wuauserv

# Firewall Changes
Write-Host "Allow ICMP Traffic through firewall"
& netsh advfirewall firewall add rule name="ALL ICMP V4" protocol=icmpv4:any,any dir=in action=allow

Write-Host "Enable WMI traffic through the firewall"
& netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable=yes

# Power Settings
Write-Host "Setting Power Performance"
$HPGuid = (Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "ElementName='High performance'").InstanceID.tostring()
$regex = [regex]"{(.*?)}$"
$PowerConfig = $regex.Match($HPGuid).groups[1].value 
& powercfg -S $PowerConfig
# Idle timeouts
powercfg.exe -x -monitor-timeout-ac 0
powercfg.exe -x -monitor-timeout-dc 0
powercfg.exe -x -disk-timeout-ac 0
powercfg.exe -x -disk-timeout-dc 0
powercfg.exe -x -standby-timeout-ac 0
powercfg.exe -x -standby-timeout-dc 0
powercfg.exe -x -hibernate-timeout-ac 0
powercfg.exe -x -hibernate-timeout-dc 0

# Disable Hibernation
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Power\ -name HiberFileSizePercent -value 0
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Power\ -name HibernateEnabled -value 0

# Set TimeZone
Write-host "Setting Time Zone to Eastern Standard Time"
Set-TimeZone -Name "Eastern Standard Time"

# Adding Authenticated Users to Remote Desktop Users
write-Host "Adding Authenticated Users to Remote Desktop Users.."
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "Authenticated Users"

# Removing OneDrive
Write-Host "Removing OneDrive..."
$onedrive = Get-Process onedrive -ErrorAction SilentlyContinue
if ($onedrive) {
  taskkill /f /im OneDrive.exe
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & $env:systemroot\SysWOW64\OneDriveSetup.exe /uninstall /q
     if (!(Test-Path HKCR:))
    {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
    }
    if (Test-Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") {
        Remove-Item -Force -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    }
    if (Test-Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") {
        Remove-Item -Force -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    }
}

# Disabling A few Windows 10 Settings:
# Reference:
# https://docs.microsoft.com/en-us/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services

$regConfig = @"
regKey,name,value,type
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE","DisablePrivacyExperience",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowCortana",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","AllowSearchToUseLocation",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","DisableWebSearch",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search","ConnectedSearchUseWeb",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata","PreventDeviceMetadataFromNetwork",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice","AllowFindMyDevice",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds","AllowBuildPreview",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Suggested Sites","Enabled",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer","AllowServicePoweredQSA",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete","AutoSuggest","no","String"
"HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Geolocation","PolicyDisableGeolocation",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\PhishingFilter","EnabledV9",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\BrowserEmulation","DisableSiteListEditing",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\FlipAhead","Enabled",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds","BackgroundSyncStatus",0,"DWord"
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer","AllowOnlineTips",0,"DWord"
"HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main","Start Page","about:blank","String"
"HKCU:\SOFTWARE\Microsoft\Internet Explorer\Control Panel","HomePage",1,"DWord"
"HKCU:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main","DisableFirstRunCustomize",1,"DWord"
"HKLM:\SYSTEM\CurrentControlSet\Services\LicenseManager","Start",4,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main","PreventFirstRunPage",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications","NoCloudApplicationNotification",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive","DisableFileSyncNGSC",1,"DWord"
"HKLM:\SOFTWARE\Microsoft\OneDrive","PreventNetworkTrafficPreUserSignIn",1,"DWord"
"HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy","HasAccepted",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Speech","AllowSpeechModelUpdate",0,"DWord"
"HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitTextCollection",1,"DWord"
"HKCU:\SOFTWARE\Microsoft\InputPersonalization","RestrictImplicitInkCollection",1,"DWord"
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo","Enabled",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo","DisabledByGroupPolicy",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy","LetAppsAccessLocation",2,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors","DisableLocation",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection","DoNotShowFeedbackNotifications",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection","AllowTelemetry",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableWindowsConsumerFeatures",1,"DWord"
"HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent","DisableTailoredExperiencesWithDiagnosticData",1,"DWord"
"HKLM:\SOFTWARE\Policies\Policies\Microsoft\Windows\System","EnableSmartScreen",0,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen","ConfigureAppInstallControlEnabled",1,"DWord"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen","ConfigureAppInstallControl","Anywhere","String"
"HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Policies\System","NoConnectedUser",3,"DWord"
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","HideFileExt",0,"DWord"
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","LaunchTo",1,"DWord"
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","Hidden",1,"DWord"
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{20D04FE0-3AEA-1069-A2D8-08002B30309D}",0,"DWord"
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu","{20D04FE0-3AEA-1069-A2D8-08002B30309D}",0,"DWord"
"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People","PeopleBand",0,"DWord"
"@

Write-host "Setting up Registry keys for additional settings.."
$regConfig | ConvertFrom-Csv | ForEach-Object {
    if(!(Test-Path $_.regKey)){
        Write-Host $_.regKey " does not exist.."
        New-Item $_.regKey -Force
    }
    Write-Host "Setting " $_.regKey
    New-ItemProperty -Path $_.regKey -Name $_.name -Value $_.value -PropertyType $_.type -force
}

# Additional registry configurations
# References:
# https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-lan-manager-authentication-level
# https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-restrict-ntlm-outgoing-ntlm-traffic-to-remote-servers
$regConfig = @"
regKey,name,value,type
"HKLM:\SYSTEM\CurrentControlSet\Control\Lsa","LmCompatibilityLevel",3,"DWord"
"HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0","NTLMMinClientSec",537395200,"DWord"
"HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0","RestrictSendingNTLMTraffic",2,"DWord"
"@

Write-host "Setting up Registry keys for additional settings.."
$regConfig | ConvertFrom-Csv | ForEach-Object {
    if(!(Test-Path $_.regKey)){
        Write-Host $_.regKey " does not exist.."
        New-Item $_.regKey -Force
    }
    Write-Host "Setting " $_.regKey
    New-ItemProperty -Path $_.regKey -Name $_.name -Value $_.value -PropertyType $_.type -force
}

# Set up PSRemoting 
$ServiceName = 'WinRM'
$arrService = Get-Service -Name $ServiceName

if ($arrService.Status -eq 'Running')
{
    Write-Host "$ServiceName Service is now Running"
}
else
{
    Write-host 'Enabling WinRM..'
    winrm quickconfig -q
    write-Host "Setting WinRM to start automatically.."
    & sc.exe config WinRM start= auto
}

# MWGA registry mods
# Write-Host "MWGA registry modifications"
# Write-Host "Importing registry keys..."

# $mwgaReg = @"
# regKey,name,value,type
# "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Policies\System","NoConnectedUser",3,"DWord"
# "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","HideFileExt",0,"DWord"
# "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","LaunchTo",1,"DWord"
# "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","Hidden",1,"DWord"
# "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel","{20D04FE0-3AEA-1069-A2D8-08002B30309D}",0,"DWord"
# "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu","{20D04FE0-3AEA-1069-A2D8-08002B30309D}",0,"DWord"
# "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People","PeopleBand",0,"DWord"
# "@

# $mwgaReg | ConvertFrom-Csv | ForEach-Object {
#     if(!(Test-Path $_.regKey)){
#         Write-Host $_.regKey " does not exist.."
#         New-Item $_.regKey -Force
#     }
#     Write-Host "Setting " $_.regKey
#     New-ItemProperty -Path $_.regKey -Name $_.name -Value $_.value -PropertyType $_.type -force
# }

# this is broken - use aka.ms/cloudshell ?
# Write-Host "Removing Microsoft Store, Mail, and Edge shortcuts from the taskbar..."
# $appname = "Microsoft Edge"
# ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
# $appname = "Microsoft Store"
# ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
# $appname = "Mail"
# ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
