﻿#Deploy the entire Solution

#Read data from XML
$Global:SettingsFile = "C:\Setup\HYDv10\Config\ViaMonstra_MDT_LAB.xml"
[xml]$Global:Settings = Get-Content $SettingsFile -ErrorAction Stop

#Set Vars
$Global:DomainName = 'CORP'
$Global:Solution = "HYDv10"
$Global:Logpath = "$env:TEMP\HYDv10" + ".log"
$Global:VMlocation = "D:\VMs"
$Global:VHDImage = "C:\Setup\VHD\WS2016-DCE_UEFI.vhdx"
$Global:MediaISO = 'C:\Setup\ISO\HYDV10.iso'

#Import-Modules
Import-Module -Global C:\Setup\Functions\VIAHypervModule.psm1
Import-Module -Global C:\Setup\Functions\VIAUtilityModule.psm1
Import-Module -Global C:\Setup\Functions\VIAXMLUtility.psm1

#Enable verbose for testing
$Global:VerbosePreference = "Continue"
#$Global:VerbosePreference = "SilentlyContinue"

#Update the settings file
#Only used in production
#C:\Setup\HYDv10\UpdateSettingsFile\Update-SettingsFile.ps1 -SettingsFile $SettingsFile

#Verify Host
C:\Setup\HYDv10\VeriFyBuildSetup\Verify-DeployServer.ps1 -SettingsFile $SettingsFile -VHDImage $VHDImage -VMlocation $VMlocation -LogPath $Logpath

#Test the CustomSettings.xml for OSD data
C:\Setup\HYDv10\CheckConfig\CheckConfig.ps1 -SettingsFile $SettingsFile -LogPath $Logpath

#Deploy VIADC01
$Global:Server = 'ADDS01'
$FinishAction = 'NONE'
C:\Setup\HYDv10\TaskSequences\DeployFABRICServer.ps1 -SettingsFile $SettingsFile -VHDImage $VHDImage -VMlocation $VMlocation -LogPath $Logpath -DomainName $DomainName -Server $Server

#Deploy VIARDGW01
$Global:Server = 'RDGW01'
$Global:Roles = 'RDGW'
$FinishAction = 'NONE'
C:\Setup\HYDv10\TaskSequences\DeployFABRICServer.ps1 -SettingsFile $SettingsFile -VHDImage $VHDImage -VMlocation $VMlocation -LogPath $Logpath -DomainName $DomainName -Server $Server -Roles $Roles -FinishAction $FinishAction

#Deploy VIASNAT01
$Global:Server = 'SNAT01'
$Global:Roles = 'SNAT'
$FinishAction = 'NONE'
C:\Setup\HYDv10\TaskSequences\DeployFABRICServer.ps1 -SettingsFile $SettingsFile -VHDImage $VHDImage -VMlocation $VMlocation -LogPath $Logpath -DomainName $DomainName -Server $Server -Roles $Roles -FinishAction $FinishAction

#Deploy VIAMDT01
$Global:Server = 'MDT01'
$Global:Roles = 'DEPL'
$FinishAction = 'NONE'
C:\Setup\HYDv10\TaskSequences\DeployFABRICServer.ps1 -SettingsFile $SettingsFile -VHDImage $VHDImage -VMlocation $VMlocation -LogPath $Logpath -DomainName $DomainName -Server $Server -Roles $Roles -FinishAction $FinishAction

#Deploy VIAMDT02
$Global:Server = 'MDT02'
$Global:Roles = 'NONE'
$FinishAction = 'NONE'
C:\Setup\HYDv10\TaskSequences\DeployFABRICServer.ps1 -SettingsFile $SettingsFile -VHDImage $VHDImage -VMlocation $VMlocation -LogPath $Logpath -DomainName $DomainName -Server $Server -Roles $Roles -FinishAction $FinishAction

#Deploy WSUS01
$Global:Server = 'WSUS01'
$Global:Roles = 'WSUS'
$FinishAction = 'NONE'
C:\Setup\HYDv10\TaskSequences\DeployFABRICServer.ps1 -SettingsFile $SettingsFile -VHDImage $VHDImage -VMlocation $VMlocation -LogPath $Logpath -DomainName $DomainName -Server $Server -Roles $Roles -FinishAction $FinishAction

#Build blank Ref Image VM
New-VIAVM -VMName VIAREF01 -VMMem 2048MB -VMvCPU 2 -VMLocation D:\VMs -DiskMode Empty -VMSwitchName UplinkswitchLAB -VMGeneration 1 -EmptyDiskSize 80GB

#Build blank VM for OSD
New-VIAVM -VMName VIAPC001 -VMMem 2048MB -VMvCPU 2 -VMLocation D:\VMs -DiskMode Empty -VMSwitchName UplinkswitchLAB -VMGeneration 1 -EmptyDiskSize 80GB #Refresh
New-VIAVM -VMName VIAPC002 -VMMem 2048MB -VMvCPU 2 -VMLocation D:\VMs -DiskMode Empty -VMSwitchName UplinkswitchLAB -VMGeneration 1 -EmptyDiskSize 80GB #Inplace
New-VIAVM -VMName VIAPC003 -VMMem 2048MB -VMvCPU 2 -VMLocation D:\VMs -DiskMode Empty -VMSwitchName UplinkswitchLAB -VMGeneration 1 -EmptyDiskSize 80GB #Replace (OLD)

New-VIAVM -VMName VIAPC004 -VMMem 2048MB -VMvCPU 2 -VMLocation D:\VMs -DiskMode Empty -VMSwitchName UplinkswitchLAB -VMGeneration 2 -EmptyDiskSize 80GB #BareMetal
New-VIAVM -VMName VIAPC005 -VMMem 2048MB -VMvCPU 2 -VMLocation D:\VMs -DiskMode Empty -VMSwitchName UplinkswitchLAB -VMGeneration 2 -EmptyDiskSize 80GB #Replace (NEW)


#Check log
Get-Content -Path $Logpath
