# This is for installing softwares in new VM-machines via Jenkins only(Dont use this script locally from your machine/Computer)


# You have to import below variable values from Auto.csv file which you can keep as per below location.
$Autocsv = Import-CSV "c:\VM\Auto.csv"

ForEach ($Item in $Autocsv)
{

    $computerName = $Item. ("computerName")
    


    write-Output "computerName: $computerName"





    # for each new VM machine first it will add into your current host machine.

    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $computerName -Force -Confirm:$false -Verbose



    # Here it will take Username and password from jenkins itself which is saved as global credentials.

    $Password = ConvertTo-SecureString "$($ENV:password)" -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ("$ENV:ServerUser", $Password)

    # To Take New PS-session with Computers

    $session = New-PSSession -computerName $computerName -Credential $creds

    $session

    # To copy software from Host to Guest Computer but first you need to keep all source file into your host machine under C:\Install location which will copy into your guest machine under C:\Users location

    Copy-Item -path "C:\install\ABCpdf.NET64.exe" -Destination "C:\Users" -ToSession $session -Verbose
    
    Copy-Item -path "C:\install\WFBS-SVC_Agent_Installer.msi" -Destination "C:\Users" -ToSession $session -Verbose
    
    Copy-Item -path "C:\install\ControlCaseAgentv2.5.exe" -Destination "C:\Users" -ToSession $session -Verbose
    Copy-Item -path "C:\install\googlechromestandaloneenterprise64.msi" -Destination "C:\Users" -ToSession $session -Verbose

    Enter-PSSession $session

    

    # To Install ABCpdfNet64 software on all host computers

    Invoke-Command -ComputerName $computerName -credential $creds -ScriptBlock {C:\Users\VMware-tools-10.2.5-8068406-i386.exe /S /v"/qn REBOOT=R"}

    Invoke-Command -ComputerName $computerName -credential $creds -ScriptBlock {Start-Process -filepath C:\Users\ControlCaseAgentv2.5.exe -Wait -PassThru}

    Invoke-Command -ComputerName $computerName -credential $creds -ScriptBlock {Start-Process -filepath C:\Users\WFBS-SVC_Agent_Installer.msi -Wait -PassThru}

    Invoke-Command -ComputerName $computerName -credential $creds -ScriptBlock {Start-Process -filepath C:\Users\googlechromestandaloneenterprise64.msi -Wait -PassThru}

    Invoke-Command -ComputerName $computerName -credential $creds -ScriptBlock { Start-Job -Name Job1 -ScriptBlock {Start-Process -filepath C:\Users\ABCpdf.NET64.exe -Wait -PassThru}; wait-Job -Name Job1 -Timeout 60 | Stop-Job}
    
    

   
    
    
    # To End PS-Session
    
    $session | Remove-PSSession


    # Here again Antivirus software copied and reinstalled as it will be done in two parts.also it will be good to make sure.

    $Password = ConvertTo-SecureString "$($ENV:password)" -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ("$ENV:ServerUser", $Password)

    $session = New-PSSession -computerName $computerName -Credential $creds

    $session

    Copy-Item -path "C:\install\WFBS-SVC_Agent_Installer.msi" -Destination "C:\Users" -ToSession $session -Verbose

    Enter-PSSession $session

    Invoke-Command -ComputerName $computerName -credential $creds -ScriptBlock { Start-Job -Name Job1 -ScriptBlock {Start-Process -filepath C:\Users\WFBS-SVC_Agent_Installer.msi -Wait -PassThru}; wait-Job -Name Job1 -Timeout 60 | Stop-Job}

    

     # To End PS-Session
    
    $session | Remove-PSSession

}