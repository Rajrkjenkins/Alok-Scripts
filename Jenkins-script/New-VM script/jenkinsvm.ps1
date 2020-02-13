$Autocsv = Import-CSV "c:\VM\Auto.csv"

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
    $localUser = $Item. ("localUser")
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
    write-Output "localUser: $localUser"
    write-Output "VM_prefix: $VM_prefix"


    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
    write-host "Connecting to vCenter Server $VcenterServer" -foreground green

    

    $Password = ConvertTo-SecureString "$($ENV:password)" -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential ("$ENV:ServerUser", $Password)


    Connect-viserver $VcenterServer -Credential $Credentials -WarningAction SilentlyContinue
    New-VM -Name $VM_prefix -template $template -ResourcePool $ResourcePool -Location $Folder
    Get-VM $VM_prefix |Get-NetworkAdapter|Set-NetworkAdapter -NetworkName $NetworkName -Confirm:$false
    Get-VM $VM_prefix | Set-VM -numcpu $numcpu -Confirm:$false
    Get-VM $VM_prefix | Set-VM -MemoryGB $GBRam -Confirm:$false
    Get-VM $VM_prefix | Get-HardDisk -Name 'Hard disk 1' | Set-HardDisk -CapacityGB $GBguestdisk -Confirm:$false
    Get-VM $VM_prefix |get-Networkadapter |Set-Networkadapter -type E1000E -Confirm:$false
    write-host "Power On of the VM $VM_prefix initiated"  -foreground green
    Start-VM -VM $VM_prefix -confirm:$false -RunAsync

    Sleep -Seconds 60

    $netsh = "c:\windows\system32\netsh.exe interface ip set address ""$NetworkName1"" static $IP $Subnet $Gateway"
    Invoke-VMScript -VM $VM_prefix -guestuser $guestuser -guestpassword $guestpassword -ScriptType bat -ScriptText $netsh

    $netsh2 = "c:\windows\system32\netsh.exe interface ip set dnsservers ""$NetworkName1"" static $DNS1"
    Invoke-VMScript -VM $VM_prefix -guestuser $guestuser -guestpassword $guestpassword -ScriptType bat -ScriptText $netsh2


    $netsh3 = "c:\windows\system32\netsh.exe interface ip add dnsservers ""$NetworkName1"" $DNS2"
    Invoke-VMScript -VM $VM_prefix -guestuser $guestuser -guestpassword $guestpassword -ScriptType bat -ScriptText $netsh3


    Get-VM $VM_prefix | Restart-VMGuest

    Sleep -Seconds 60

    $Password = ConvertTo-SecureString "$($ENV:password)" -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential ("$ENV:ServerUser", $Password)


    $pw = convertto-securestring $guestpassword -AsPlainText -Force
    $localCredentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $localUser,$pw
    
   
    Rename-Computer -ComputerName $IP -NewName $NewName -LocalCredential $localCredentials -DomainCredential $credentials -restart -Force -PassThru

    Sleep -Seconds 60


    $Password = ConvertTo-SecureString "$($ENV:password)" -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential ("$ENV:ServerUser", $Password)


    $pw = convertto-securestring $guestpassword -AsPlainText -Force
    $localCredentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $localUser,$pw
    

    add-computer -computerName $NewName -domainname MOTIONSOFT.com -LocalCredential $localCredentials -Credential $Credentials -restart -force

    write-host "Computer Name is"$NewName  "UserName is"$guestuser "and Password is $guestpassword" -ForegroundColor Yellow


    Disconnect-VIServer -Server $VcenterServer -Force -Confirm:$false

}