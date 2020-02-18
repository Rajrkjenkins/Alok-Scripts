# this Script is for RK-Vcenter and you can run it from any jump server to create new VMs.
# Befor running this script need to do two tasks.
# Fisrt task: Check the VMware-PowerCli module is installed or not in jump server(Refer one word file "VM automation" which will be in same folder.
# Second task: You dont have to put your username and password again and again so Pls Run "GetCredentials" script which is in same folder.

# This Script will not work in Jenkins server.only will be work on jump server.


# Here you have to put all your configuration into Auto.csv file which you can keep at any places but Always put that location below.

$Autocsv = Import-CSV "C:\Users\Administrator\Documents\Auto.csv"  #put your file location

ForEach ($Item in $Autocsv)
{

    $VcenterServer = $Item. ("VcenterServer")
    $VcenterServerUser = $Item. ("VcenterServerUser")
    $VcenterServerUserPassword = $Item. ("VcenterServerUserPassword")
    $Vmcount = $Item. ("Vmcount")
    $ResourcePool = $Item. ("ResourcePool")
    $template = $Item. ("template")
    $Folder = $Item. ("Folder")
    $numcpu = $Item. ("numcpu")
    $GBRam = $Item. ("GBRam")
    $GBguestdisk = $Item. ("GBguestdisk")
    $Typeguestdisk = $Item. ("Typeguestdisk")
    $GuestOS = $Item. ("GuestOS")
    $ds = $Item. ("ds")
    $NetworkName = $Item. ("NetworkName")
    $cd = $Item. ("cd")
    $isopath = $Item. ("isopath")
    $Cluster = $Item. ("Cluster")
    $Subnet = $Item. ("Subnet")
    $NetworkName1 = $Item. ("NetworkName1")
    $Gateway = $Item. ("Gateway")
    $DNS1 = $Item. ("DNS1")
    $DNS2 = $Item. ("DNS2")
    $guestuser = $Item. ("guestuser")
    $guestpassword = $Item. ("guestpassword")
    $IP = $Item. ("IP")
    $NewName = $Item. ("NewName")
    $VM_prefix = $Item. ("VM_prefix")

    write-Output "VcenterServer: $VcenterServer"
    write-Output "VcenterServerUser: $VcenterServerUser "
    write-Output "VcenterServerUserPassword: $VcenterServerUserPassword"
    write-Output "Vmcount: $Vmcount"
    write-Output "ResourcePool: $ResourcePool"
    write-Output "template: $template"
    write-Output "Folder: $Folder"
    write-Output "numcpu: $numcpu"
    write-Output "GBRam: $GBRam"
    write-Output "GBguestdisk: $GBguestdisk"
    write-Output "Typeguestdisk: $Typeguestdisk"
    write-Output "GuestOS: $GuestOS"
    write-Output "ds: $ds"
    write-Output "NetworkName: $NetworkName"
    write-Output "cd: $cd"
    write-Output "isopath: $isopath"
    write-Output "Cluster: $Cluster"
    write-Output "Subnet: $Subnet"
    write-Output "NetworkName1: $NetworkName1"
    write-Output "Gateway: $Gateway"
    write-Output "DNS1: $DNS1"
    write-Output "DNS2: $DNS2"
    write-Output "guestuser: $guestuser"
    write-Output "guestpassword: $guestpassword"
    write-Output "IP: $IP"
    write-Output "NewName: $NewName"
    write-Output "VM_prefix: $VM_prefix"


    # Below command is for Certification authentification of PowerCLI

    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false


     # Here it will take password from Below location which will be in encrypted Format and only you need to change username.

    $Password = Get-Content “C:\test\password.txt” | ConvertTo-SecureString
    $Credentials = New-Object System.Management.Automation.PSCredential ("motionsoft\asingh",$Password) # Put your username here
    


     # It will create VM as per given template but later it will be customized as per your filled data into Auto.csv file
 
    write-host "Connecting to vCenter Server $VcenterServer" -foreground green
    Connect-viserver $VcenterServer -Credential $Credentials -WarningAction 0
    New-VM -Name $VM_prefix -template $template -ResourcePool $ResourcePool -Location $Folder
    Get-VM $VM_prefix |Get-NetworkAdapter|Set-NetworkAdapter -NetworkName $NetworkName -Confirm:$false
    Get-VM $VM_prefix | Set-VM -numcpu $numcpu -Confirm:$false
    Get-VM $VM_prefix | Set-VM -MemoryGB $GBRam -Confirm:$false
    Get-VM $VM_prefix | Get-HardDisk -Name 'Hard disk 1' | Set-HardDisk -CapacityGB $GBguestdisk -Confirm:$false
    Get-VM $VM_prefix |get-Networkadapter |Set-Networkadapter -type E1000E -Confirm:$false
    write-host "Power On of the VM $VM_prefix initiated"  -foreground green
    Start-VM -VM $VM_prefix -confirm:$false -RunAsync

    Sleep -Seconds 60


    # Now it will configure Network-Setup for machine.

    $netsh = "c:\windows\system32\netsh.exe interface ip set address ""$NetworkName1"" static $IP $Subnet $Gateway"
    Invoke-VMScript -VM $VM_prefix -guestuser $guestuser -guestpassword $guestpassword -ScriptType bat -ScriptText $netsh

    $netsh2 = "c:\windows\system32\netsh.exe interface ip set dnsservers ""$NetworkName1"" static $DNS1"
    Invoke-VMScript -VM $VM_prefix -guestuser $guestuser -guestpassword $guestpassword -ScriptType bat -ScriptText $netsh2


    $netsh3 = "c:\windows\system32\netsh.exe interface ip add dnsservers ""$NetworkName1"" $DNS2"
    Invoke-VMScript -VM $VM_prefix -guestuser $guestuser -guestpassword $guestpassword -ScriptType bat -ScriptText $netsh3

    Get-VM $VM_prefix | Restart-VMGuest

    Sleep -Seconds 60


     # Now it will Rename the VMs.
    
    Rename-Computer -ComputerName $IP -NewName $NewName -Restart -Force

    Sleep -Seconds 60

    # Here it will take password from Below location which will be in encrypted Format and only you need to change username.

    $Password = Get-Content “C:\test\password.txt” | ConvertTo-SecureString
    $Credentials = New-Object System.Management.Automation.PSCredential ("motionsoft\asingh",$Password) # Put your username here
    

    # It will add into Motionsoft.com domain

    add-computer -computerName $NewName -domainname MOTIONSOFT.com -Credential $Credentials -restart -force

}