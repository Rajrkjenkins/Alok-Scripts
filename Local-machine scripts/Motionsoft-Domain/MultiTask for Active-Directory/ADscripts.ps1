 #This script is for Multiple task of Active-Directory but it will run locally in AD Server.
 # You need to change File location as per your requirement which is given in this script to import and Export the file. 
 
 Import-Module Active-Directory
 
 # To Perform Active Directory tasks

 Write-Host "1- Create an account" -ForegroundColor Yellow
 Write-Host "2- Reset password" -ForegroundColor Yellow
 Write-Host "3- add MultiUsers into multigroupst" -ForegroundColor Yellow
 Write-Host "4- Find Computer Type of AD" -ForegroundColor Yellow
 Write-Host "5- disable the MultiADComputer" -ForegroundColor Yellow
 Write-Host "6- Find a Empty Groups" -ForegroundColor Yellow
 Write-Host "7- disable the Useraccounts" -ForegroundColor Yellow
 Write-Host "8- Enable the UsersAccounts" -ForegroundColor Yellow
 Write-Host "9- Enumerate Members of a Group" -ForegroundColor Yellow
 Write-Host "10- Find Obsolete computer Accounts" -ForegroundColor Yellow
 Write-Host "11- remove the UserAccounts/Users" -ForegroundColor Yellow
 Write-Host "12- Unlock the MultiUsers" -ForegroundColor Yellow
 Write-Host "13- Remove MultiUsers From multigroups" -ForegroundColor Yellow
 Write-Host "14- Exit" -ForegroundColor Yellow

switch(Read-Host "Select a menu item"){



    1 { # Create the AD User
        

        $Accountcsv = Import-Csv "C:\Alok\Account.csv"   #Use Individual CSV file(Account.csv) for this option

        Foreach ($Item in $Accountcsv)
        {

          $Name = $Item. ("Name")
          $NewPassword = $Item. ("NewPassword")
          $FirstName = $Item. ("FirstName")
          $LastName = $Item. ("LastName")
          $UserName = $Item. ("UserName")
          

          write-Output "Name: $Name"
          write-Output "NewPassword: $NewPassword"
          write-Output "FirstName: $FirstName"
          write-Output "LastName: $LastName"
          write-Output "UserName: $UserName"
          


           New-ADUser `
               -Name $Name `
               -GivenName $FirstName `
               -Surname $LastName `
               -UserPrincipalName $UserName `
               -AccountPassword (convertTo-SecureString "Motionsoft@123" -AsPlainText -Force) `
               -Path "OU=Contractors,DC=MOTIONSOFT,DC=com" `
               -Enabled 1

          $process = Get-ADUser -Identity $Name
          Write-Output $process

            }


          #Call myScript1 from myScript2
          Invoke-Expression "C:\Alok\ADscripts.ps1"

         }



    2 {# To Reset password of  the MultiUsers using CSV file

        $ADcsv = Import-Csv "C:\Alok\AD.csv"

        Foreach ($Item in $ADcsv)
{

    $samAccountName = $Item. ("samAccountName")
    $password = $Item. ("password")

    write-Output "samAccountName: $samAccountName"
    write-Output "password: $password"

   $AccountName = Get-ADUser $samAccountName
   Get-ADUser -Identity $AccountName
   Set-ADAccountPassword -Identity $AccountName -Reset -NewPassword (ConvertTO-SecureString -ASPlainText $password -Force)

 }

  #Call myScript1 from myScript2
  Invoke-Expression "C:\Alok\ADscripts.ps1"

 }



    3 {# To add MultiUsers into multigroups using CSV file

      $ADcsv = Import-Csv "C:\Alok\AD.csv"

      Foreach ($Item in $ADcsv)
         {

           $samAccountName = $Item. ("samAccountName")
           $groups = $Item. ("groups")

           write-Output "samAccountName: $samAccountName"
           write-Output "groups: $groups"


           Add-ADGroupMember -Identity $groups -Member $samAccountName
           $process = Get-ADuser -Identity $AccountName -Properties MemberOf
           Write-Output $process


             }
      #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"
 
 }



    4 {   # To Find Computer Type of Active Directory

      $path = "C:\Alok\type.csv"

      Get-ADComputer -Filter * | Export-Csv -path $path -NoTypeInformation
      
      
      #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"
      
      }


    5 {   # To disable the MultiADComputer using CSV file
          # Always Use SamAccountName of ADcomputer in ADAccount variable

       $ADcsv = Import-Csv "C:\Alok\AD.csv"

       Foreach ($Item in $ADcsv)
{ 

    $ADAccount = $Item. ("ADAccount")

    write-Output "ADAccount: $ADAccount"
    
    
    Disable-ADAccount -Identity $ADAccount
    $process = Get-ADComputer -Identity $ADAccount
    Write-Output $process

  }


      #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"

}


    6 {  # To Find a Empty Groups in Active Directory


      Import-Module ActiveDirectory

      $path = "C:\Alok\groupname.csv"

      get-adgroup -filter * | where {-Not ($_ | get-adgroupmember)} | Select Name | Export-Csv -path $path -NoTypeInformation

      #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"


}



    7 { # To disable the MultiUsers using CSV file
        # Maintain another CSV file Enable for this task
       

       $Enabledcsv = Import-Csv "C:\Alok\Enabled.csv"

       Foreach ($Item in $Enabledcsv)
{ 

    $samAccountName = $Item. ("samAccountName")

    write-Output "samAccountName: $samAccountName"
     
    
    $ADAccount = Get-ADUser $samAccountName
    Get-ADUser -Identity $ADAccount | Disable-ADAccount

    $process = Get-ADUser -Identity $ADAccount
    Write-Output $process
}



       #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"

}


    8 {  # To Enable the MultiUsers using CV file
         # Maintain another CSV file Enable for this task

     $Enabledcsv =  Import-CSV "C:\Alok\Enabled.csv"

     Foreach ($Item in $Enabledcsv)
{ 

    $samAccountName = $Item. ("samAccountName")

    write-Output "samAccountName: $samAccountName"
     
    
    $ADAccount = Get-ADUser $samAccountName
    Get-ADUser -Identity $ADAccount | Enable-ADAccount

    $process = Get-ADUser -Identity $ADAccount
    Write-Output $process

}



        #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"

}


    9 {  # To Enumerate Members of a Group
         # Need To Use Seperate CSV file for this task

       $groups = Get-Content C:\Alok\Name.csv

       $list= Foreach ( $group in $groups) { Get-ADGroupMember -Identity $group | Select-Object $group,name | Format-Table}

       $list | Out-File C:\Alok\list.csv
       
       #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"
       
       }


    10 { # To Find Obsolete computer Accounts 

         $DaysInactive = 90

         $time = (Get-Date).Adddays(-($DaysInactive))
 
         $path = "C:\Alok\obsolete.csv"

         Get-ADComputer -Filter {LastLogonDate -lt $time} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, lastlogonDate | Export-Csv -path $path -NoTypeInformation


         #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"


}

    11 { # To remove the MultiUsers using CSV file

        $ADcsv = Import-Csv "C:\Alok\AD.csv"

        Foreach ($Item in $ADcsv)
        {

          $samAccountName = $Item. ("samAccountName")

          write-Output "samAccountName: $samAccountName"

          Get-ADUser -Identity $samAccountName
          Remove-ADUser -Identity $samAccountName -Confirm:$false
          Get-ADUser -Identity $samAccountName -Properties *
            }
  
      #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"
 
 
 }
    12 {  # To Unlock the MultiUsers using CSV file

       $Unlockcsv = Import-Csv "C:\Alok\AD.csv"

       Foreach ($Item in $ADcsv)
       {

          $samAccountName = $Item. ("samAccountName")

          write-Output "samAccountName: $samAccountName"

          Get-ADUser -Identity $samAccountName -Properties LockedOut | Select-Object Name,LockedOut
          Unlock-ADAccount -Identity $samAccountName
          Get-ADUser -Identity $samAccountName -Properties LockedOut | Select-Object Name,LockedOut

            }
 
      #Call myScript1 from myScript2
      Invoke-Expression "C:\Alok\ADscripts.ps1"
 
 
 }

    13 { # To Remove MultiUsers From multigroups using CSV file

        $ADcsv = Import-Csv "C:\Alok\AD.csv"

        Foreach ($Item in $ADcsv)
        {

            $samAccountName = $Item. ("samAccountName")
            $groups = $Item. ("groups")

            write-Output "samAccountName: $samAccountName"
            write-Output "groups: $groups"


            Remove-ADGroupMember -Identity $groups -Member $samAccountName -Confirm:$false
            $process = Get-ADuser -Identity $samAccountName -Properties MemberOf
            Write-Output $process

            }
 
            #Call myScript1 from myScript2
            Invoke-Expression "C:\Alok\ADscripts.ps1"
 
 }

    14 {exit}
}
