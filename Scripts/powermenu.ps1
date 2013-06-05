#===========================================================================================================================
#	
# 
#   FILE:  powermenu.ps1
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



function mainMenu()
{
	Clear-Host;
	Write-Host "============";
	Write-Host "= MAINMENU =";
	Write-Host "============";
	Write-Host "1. Press '1' VM auto provision";
}
function returnMenu($option)
{
	Clear-Host;
	Write-Host "You chose option $option";
	Write-Host "Press any key to return to the main menu.";
	$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
}
do
{
	mainMenu;
	$input = Read-Host "Enter a number for an option or type `"quit`" to finish."
	switch ($input)
	{
		"1"
		{
			C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -psc "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\vim.psc1" -noe -file "c:\scripts\oscust.ps1"
			returnMenu $input;
		}
		"quit"
		{
			# nothing
		}
		default
		{
			Clear-Host;
			Write-Host "Invalid input. Please enter a valid option. Press any key to continue.";
			$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
		}
	}
} until ($input -eq "quit");
Clear-Host;