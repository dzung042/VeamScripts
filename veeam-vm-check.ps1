#===============================================================================
#
#          FILE:  veeam-vm-check.ps1
# 
# 
#   DESCRIPTION: Checks all Veeam Backup Jobs lists VMs and compares to Vcenter 
# 				 for missing VMs not being backup - sends out via email.
#
#         NOTES:  ---
#        AUTHOR:  Robbi Hatcher (), robbi.hatcher@mmspos.com
#       COMPANY:  Master Merchant Systems
#       VERSION:  1.0
#       CREATED:  31/05/13 12:18:43 AM AST
#===============================================================================

# Load Veeam Powershell module. Without this it is it will fail.

asnp "VeeamPSSnapIn" -ErrorAction SilentlyContinue

########################## Configuration##########################


# vCenter server hostname
$vcenter = "SERVERHOSTNAME"

# To Exclude VMs from report add VM names to be excluded as follows
# $excludevms=@("vm1","vm2")
$excludevms=@()

# Temp file for output
$tempfile = 'c:\Scripts\vms.txt'

#SMTP Config
$emailFrom = "veeam@domain.com"
$emailTo = "operations@domain.com"
$subject = "Veeam missing backups"
$smtpServer = "HOSTIP"


####################################################################

$vcenterobj = Get-VBRServer -Name $vcenter

# Build hash table with excluded VMs
$excludedvms=@{}
foreach ($vm in $excludevms) {
    $excludedvms.Add($vm, "Excluded")
}

# Get a list of all VMs from vCenter and add to hash table, assume Unprotected
$vms=@{}
foreach ($vm in (Find-VBRObject -Server $vcenterobj | Where-Object {$_.Type -eq "VirtualMachine"}))  {
    if (!$excludedvms.ContainsKey($vm.Name)) {
        $vms.Add($vm.Name, "Unprotected")
    }
}

# Find all backup job sessions that have ended in the last 24 hours
$vbrsessions = Get-VBRBackupSession | Where-Object {$_.JobType -eq "Backup" -and $_.EndTime -ge (Get-Date).addhours(-24)}

# Find all successfully backed up VMs in selected sessions (i.e. VMs not ending in failure) and update status to "Protected"
foreach ($session in $vbrsessions) {
    foreach ($vm in ($session.gettasksessions() | Where-Object {$_.Status -ne "Failed"} | ForEach-Object { $_ })) {
        if($vms.ContainsKey($vm.Name)) {
            $vms[$vm.Name]="Protected"
        }
    }
}

# Output VMs based on status.
foreach ($vm in $vms.Keys)
{
  if ($vms[$vm] -eq "Protected") {
	   "$vm is backed up," | out-file -append $tempfile
       write-host "$vm is backed up"
  } else {
       write-host "$vm is NOT backed up"
	   "$vm is NOT backed up," | out-file -append $tempfile
  } 
} 

# SMTP send and delete file
$smtpoutput = Get-Content $tempfile
$Emailbody += "$smtpoutput"
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($emailFrom, $emailTo, $subject, $Emailbody)
remove-item $tempfile
