#===========================================================================================================================
#	Run powermenu.ps1 instead of this.
# 
#   FILE:  oscust.ps1
# 
# 
#   DESCRIPTION: 	Mass Create VMs and assign to Veeam backup jobs and adds DNS A and PTR records
#
#   TESTED: 		Linux VM centos 6.0 [WITH REDHAT 5 OS TEMPLATE] , vCenter 5.1, Veeam 6.5, 
#					Server 2008 x64 r2 DNS. Script is ran on veeam server also 2008 x64 r2.
#
#   Required: 		Powercli for Vmware PS addon , vsphere 5.1 client for VIX support and Veeam PS addon
#					all on a 64 bit server. 
#
#   NOTES:  		Start the script off with powercli in 32 bit mode. The script will
#				  	will switch to 64 bit when required. VMware needs 32bit and veeam needs 64bit. Quite annoying.
#					Also I run CENTOS6 and needed to switch from centos5/6 to redhat 5 os type for the clone to work right with static IPs.
#					Curious to see how this works with other distros of linux. Will require some work I believe due to the perl script
#					inside the powercli scripts folders for linux network changes which are redhat based.   
#
#	To Do:			Windows support, multi nics, cluster isolate VM rules, make script functions and logic based to make script
#					modular needing only one script. Coming soon! 
#	  
#
#
#   AUTHOR:  		Robbi Hatcher (), robbi.hatcher@mmspos.com
#   COMPANY:  		Master Merchant Systems
#   VERSION:  		1.0
#   CREATED:  		06/05/13 19:18:43 PM AST
#=============================================================================================================================
asnp "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue
write-host 'Finished loading VMware Power Script Module' -foregroundcolor "red" -backgroundcolor "white"
write-host

#vCENTER user/pass info - the only thing you should need to modify

$vcenter = "vcenterSERVERNAME"
$user = "administrator"
$pass = "PASSWORD"

Connect-VIServer -Server $vcenter -Protocol https -User $user -Password $pass | out-null

# Import the template to build and import your VM specs
$vmlist = Import-CSV C:\Scripts\create-servers.csv

# Next 3 variables are for finding a server in the cluster that is using the least CPU. Replace $newhost with $item.host 
# on line 70 and fill in the CSV for a non cluster server .
# $OriginalSRV get any VM inside the cluster. Only way I could figure this out without using resource pools. 
$OriginalSRV = Get-VM "vital"
$OriginalCluster = $OriginalSRV | Get-Cluster
$NewHost = $OriginalCluster | Get-VMHost | Sort-object -property CPuUsageMhz, name -Descending | Select-object -last 1





foreach ($item in $vmlist) {
#CSV template. Each $item is a column
$vmname = $item.name
$ipaddr1 = $item.ipaddress
$subnet1 = $item.subnet
$gateway1 = $item.gateway
$dns = $item.dns
$ostype = $item.ostype
$osdomain = $item.osdomain
$memory = $item.memory
$cpu = $item.cpu
$adapter1 = $item.NetworkAdapter
$portgroup1 = $item.portgroup
$Template = $item.template
$VMHost = $item.host
$Datastore = $item.datastore
$tempcust = $item.NonPersistent
$OStemp = $item.customization
$ds = $NewHost | Get-Datastore $item.datastore

write-host
write-host 'Starting to clone' $item.name 'from' $item.template -foregroundcolor "blue" -backgroundcolor "white"
# Sets up a temp OS Customization for Linux only. inputs DNS, Domain, and static IP 
New-OSCustomizationSpec -name $item.NonPersistent -type nonpersistent -OSType  $item.ostype -NamingScheme vm -Domain $item.osdomain -DnsServer $item.dns | out-null
Get-OSCustomizationSpec $item.NonPersistent | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping `
-IpMode UseStaticIP -IpAddress $item.ipaddress -SubnetMask $item.subnet -DefaultGateway $item.gateway | out-null

# Creates a new VM using the temp OS customization, picks ESXi Server a Datastore 
New-VM -Name $item.name  -OSCustomizationSpec $item.NonPersistent -Template $item.template -VMHost $NewHost -Datastore $ds | out-null

# Deletes temp OS Customization and reuses for next batch VM
Remove-OSCustomizationSpec $item.NonPersistent -Confirm:$false | out-null

# Updates cloned VM CPU and Memory options
write-host 'changing memory to' $item.memory 'cpu cores to' $item.cpu -foregroundcolor "blue" -backgroundcolor "white"
get-vm $item.name | set-vm -MemoryMB $item.memory -NumCpu $item.cpu -Confirm:$false | out-null

# Powers Up the VM
Start-VM -VM $item.name -Confirm:$false -RunAsync | out-null

# Sets up the network 
write-host 'Ip Address Set to' $item.ipaddress 'Network changed to' $item.portgroup -foregroundcolor "blue" -backgroundcolor "white"
get-vm $item.name | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $item.portgroup -Confirm:$false  | out-null
write-host

# Sets network to always be connected
get-vm $item.name | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$true -Connected:$true -Confirm:$false | out-null
write-host 'finished setting up' $item.name'! ' -foregroundcolor "blue" -backgroundcolor "white"
write-host
write-host
}

# Calls the next script that can be run in 64bit (Veeam and DNS updates)
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -version 2 c:\scripts\veeambu.ps1




