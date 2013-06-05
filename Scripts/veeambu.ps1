#===========================================================================================================================
#	Run powermenu.ps1 instead of this.
# 
#   FILE:  veeambu.ps1
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
#==============================================================================================================================


# am I running in 32 bit shell?
if ($pshome -like "*syswow64*") {
	# relaunch this script under 64 bit shell
	# if you want powershell 2.0, add -version 2 *before* -file parameter
	& (join-path ($pshome -replace "syswow64", "sysnative") powershell.exe) -file `
		(join-path $psscriptroot $myinvocation.mycommand) @args
	# exit 32 bit script
	exit
}

#Load Veeam Snap in. 
asnp "VeeamPSSnapin"
write-host 'Finished loading Veeam Power Script Module' -foregroundcolor "red" -backgroundcolor "white"
write-host

# Import the template to build and import your VM specs
$vmlist = Import-CSV C:\Scripts\create-servers.csv


#Adds VMs to Backup jobs
foreach ($item in $vmlist) {
write-host adding $item.name to Veeam Backup $item.backupjob
$vmname = $item.name
$vcserver = $item.vcserver
$veeamjobname = $item.backupjob 
$vbrjob = Get-VBRJob | Where {$_.Name -eq $veeamjobname}
$veeamserver = Get-VBRServer | Where {$_.Name -eq $item.vcserver}
Add-VBRJobObject -Job $vbrjob -Server $veeamserver -Object $item.name | out-null
}

# Add VMs to DNS A and PTR records 
foreach ($item in $vmlist) {
$vmname = $item.name
$ipaddr1 = $item.ipaddress
$zone = $item.osdomain
$dns = $item.dnsserver  
    dnscmd $item.dnsserver /recordadd $zone $item.name /createPTR A $item.ipaddress 
}