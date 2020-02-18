# This is used to generate encrypted format of Your USER-Name and Password

$Credentials = Get-Credential
$Credentials.Password | ConvertFrom-SecureString | Set-Content C:\Alok\password.txt # To Put Your location for File
$Username = $Credentials.Username
$Password = Get-Content “C:\Alok\password.txt” | ConvertTo-SecureString  # To give same location of above File
$Credentials = New-Object System.Management.Automation.PSCredential $Username,$Password
$Password = $Credentials.GetNetworkCredential().Password

