
#===============================================================================
#
#          FILE:  veeam-vm-list.ps1
# 
# 
#   DESCRIPTION: Checks all Veeam Backup Jobs lists VMs and checks all  
# 				 VM's in Vcenter. Output to screen. 
#
#         NOTES:  ---
#        AUTHOR:  Robbi Hatcher (), robbi.hatcher@mmspos.com
#       COMPANY:  Master Merchant Systems
#       VERSION:  1.0
#       CREATED:  31/05/13 12:18:43 AM AST
#===============================================================================

# vCenter server
$vcenter = "SERVERHOSTNAME"
$user = "USERNAME"
$pass = "PASSWORD"

# Add the Veeam Backup jobs - actual name of the job. Add or remove as needed. 
$backup1 = "BACKUP1"
$backup2 = "BACKUP2"
$backup3 = "BACKUP3"
$backup4 = "BACKUP4"
$backup5 = "BACKUP5"
$backup6 = "BACKUP6"
$backup7 = "BACKUP7"
$backup8 = "BACKUP8"


# To Exclude VMs from report add VM names to be excluded as follows
# $excludevms=@("vm1","vm2")
$excludedvms=@()

# Do not edit below unless increasing/decreasing the amount of jobs.

#================================================================================

echo 'Setting up Veeam and VMware PS modules'
# Load Veeam and vmware Powershell module. Without this it is it will fail

asnp "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue
asnp "VeeamPSSnapIn" -ErrorAction SilentlyContinue


$job = Get-VBRJob -name "$backup1"
$job.GetObjectsInJob() | foreach { $_.Location } | Foreach-object {
    $_ -replace 'vcenter41', "$backup1"
} 


$job = Get-VBRJob -name "$backup2"
$job.GetObjectsInJob() | foreach { $_.Location } | Foreach-object {
    $_ -replace 'vcenter41', "$backup2"
} 

$job = Get-VBRJob -name "$backup3"
$job.GetObjectsInJob() | foreach { $_.Location } | Foreach-object {
    $_ -replace 'vcenter41', "$backup3"
} 

$job = Get-VBRJob -name "$backup4"
$job.GetObjectsInJob() | foreach { $_.Location } | Foreach-object {
    $_ -replace 'vcenter41', "$backup4"
} 

$job = Get-VBRJob -name "$backup5"
$job.GetObjectsInJob() | foreach { $_.Location } | Foreach-object {
    $_ -replace 'vcenter41', "$backup5"
} 

$job = Get-VBRJob -name "$backup6"
$job.GetObjectsInJob() | foreach { $_.Location } | Foreach-object {
    $_ -replace 'vcenter41', "$backup6"
} 

$job = Get-VBRJob -name "$backup7"
$job.GetObjectsInJob() | foreach { $_.Location } | Foreach-object {
    $_ -replace 'vcenter41', "$backup7"
} 

$job = Get-VBRJob -name "$backup8"
$job.GetObjectsInJob() | foreach { $_.Location  } | Foreach-object {
    $_ -replace 'vcenter41', "$backup8" 
} 


echo 'Connecting to Vcenter - grabbing all VMs'

#connects to Vcenter
Connect-VIServer -Server $vcenter -Protocol https -User $user -Password $pass | out-null


#Displays all the VMs
Get-VM | foreach { $_.Name }

