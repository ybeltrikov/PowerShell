<#
.SYNOPSIS
This is a script creating a new corporate user

.DESCRIPTION
Script to automate new user account creation. It will prompt for the new user full name, OU, Title and Extension and will create:
- CorpAccount account with temporary password
- homedir folder for the user and sets permissions
- Alternative domain account for systems not supporting  and save the details to network share

FURTHER DEVELOPMENT.
- Error for users:
    -- with spaces in the names: Paul van Dyk
    -- too long names: 

#>


#Creating new Corp UK user

# 1 - Get the user's info
$FirstName = Read-Host "First name"
$LastName = Read-Host "Last name"
$Title = Read-Host "Title"
$Extension = Read-Host "Extension"
$Department = Read-Host "Department"
$Company = "Company Name"

$Office = "London"
$NewUserDomain = "@corpdomain.local"

$NewUserName = ($FirstName + "." + $LastName).ToLower()
$NewUserEmail = $NewUserName + "@corpemail.com"
$NewUserPrincipalName = $NewUserName + $NewUserDomain
$NewUserDisplayName = $FirstName + " " + $LastName

$TempPassword = 'SomeTempOne22'
$SecureStringPassword = ConvertTo-SecureString -String $TempPassword -AsPlainText -Force

# 2- Create AD accounts
Write-Host "Creating New AD user $NewUserName"
#Write-Verbose -Message "Creating New AD user: $NewUserName"

$ParentOU = "OU=London,OU=parerntou,DC=corpdomain,DC=local"
#List all OUs and ask where to put the account
Get-ADOrganizationalUnit -SearchBase $ParentOU -SearchScope OneLevel -Filter * | Select-Object -ExpandProperty Name | Write-Host 
Write-Host 
$NewUserOU = Read-Host "Which OU? (from the above)"
$TargetOU = "OU=$NewUserOU," + $ParentOU

#create a new AD user in corp domain - New-ADUser cmdlet - 
#https://docs.microsoft.com/en-us/powershell/module/addsadministration/new-aduser?view=win10-ps
$NewUser = New-ADUser -UserPrincipalName $NewUserPrincipalName -SamAccountName $NewUserName -AccountPassword $SecureStringPassword -Name $NewUserDisplayName -GivenName $FirstName -Surname $LastName -DisplayName $NewUserDisplayName -Title $Title -OfficePhone $Extension -Path $TargetOU -Office $Office -Company $Company -Department $Department -EmailAddress $NewUserEmail -ChangePasswordAtLogon $true -PassThru -Confirm

#create a new AD user in altdomain with random password - for spark and RocketChat

#generate random pass https://devblogs.microsoft.com/scripting/generate-random-letters-with-powershell/
$RandomPass = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
$SpecialCharacter = -join ((33..63) | Get-Random -Count 1 | % {[char]$_})
$RandomPass = $RandomPass + $SpecialCharacter

#create the account
$altdomainNewUserDomain = "@altdomain.local"
$altdomainNewUserName = ($FirstNameLetter + $LastName).ToLower()
$altdomainNewUserPrincipalName = $altdomainNewUserName + $altdomainNewUserDomain
$altdomainNewUserDisplayName = $FirstName + " " + $LastName
$altdomainOU = "OU=Users,OU=UK,OU=altdomain,DC=altdomain,DC=local"
$altdomainServer = "dc05.altdomain.local"
$NewaltdomainUser = New-ADUser -Server $altdomainServer -UserPrincipalName $altdomainNewUserPrincipalName -SamAccountName $altdomainNewUserName -AccountPassword $RandomSecureStringPassword -Name $altdomainNewUserDisplayName -GivenName $FirstName -Surname $LastName -DisplayName $altdomainNewUserDisplayName -Title $Title -OfficePhone $Extension -Path $altdomainOU -Office $Office -ChangePasswordAtLogon $true -Company $Company -Department $Department -EmailAddress $NewUserEmail -PasswordNeverExpires $true -CannotChangePassword $trueget- -PassThru -Confirm

#save the user details to network share J:\I.T\Keys and IDs\altdomain logins
$CredentialsFolder = "J:\I.T\Keys and IDs\altdomain logins\"
$CredentialsFilename = $altdomainNewUserName + ".txt"
$CredentialsFullFilename = $CredentialsFolder + $CredentialsFilename

$altdomainNewUserName | Out-File -FilePath $CredentialsFullFilename
$RandomPass | Out-File -FilePath $CredentialsFullFilename -Append

# 3 - Add the altdomainuk and altdomain users to the default groups
$DefaultUKGroups = 'CN=KAV_USB_London_deny,OU=KAV,OU=Security Group,DC=altdomainuk,DC=local', 'CN=Print_HPM775f_Colour,OU=Printserver,OU=Security Group,DC=altdomainuk,DC=local','CN=Map_J,OU=Security Group,DC=altdomainuk,DC=local','CN=Map_K,OU=Security Group,DC=altdomainuk,DC=local','CN=MAP_R,OU=Security Group,DC=altdomainuk,DC=local','CN=Print_HPM775f_Finance_Colour,OU=Printserver,OU=Security Group,DC=altdomainuk,DC=local','CN=Proxy_Users,OU=Security Group,DC=altdomainuk,DC=local'
$DefaultUKGroups | Get-ADGroup | Add-ADGroupMember -Members $NewUser

$DefaultaltdomainGroups = "CN=Access.APP.RocketChatMembers,OU=RocketChat,OU=Applications,OU=Access Groups,DC=altdomain,DC=local"
$DefaultaltdomainGroups | Get-ADGroup -Server $altdomainServer | Add-ADGroupMember -Server $altdomainServer -Members $NewaltdomainUser

# 4 - Create homedir and set permissions
# https://blogs.msdn.microsoft.com/johan/2008/10/01/powershell-editing-permissions-on-a-file-or-folder/
$HomeDirLocation = '\\path\to\Userhome'
$HomeFolderName = $HomeDirLocation + "\" + $NewUserName
$UserHomeFolder = New-Item -ItemType Directory -Path $HomeFolderName -Confirm
$FolderAcl = Get-Acl $UserHomeFolder
$AddNewPermissions = New-Object System.Security.AccessControl.FileSystemAccessRule($NewUser.SID,"Modify","ContainerInherit, ObjectInherit", "None", "Allow")
$FolderAcl.AddAccessRule($AddNewPermissions)

#the next line used to produce errors  
#https://social.technet.microsoft.com/Forums/ie/en-US/295f196a-f213-4f66-a608-1743a6bda787/cannot-use-setacl-properly-despite-being-file-owner-and-being-a-member-of-administrators-group?forum=winserverpowershell
#https://social.technet.microsoft.com/Forums/scriptcenter/en-US/87679d43-04d5-4894-b35b-f37a6f5558cb/solved-how-to-take-ownership-and-change-permissions-for-blocked-files-and-folders-in-powershell

try {
    Set-Acl -Path $UserHomeFolder -AclObject $FolderAcl    
}
catch {
    Write-Host "Set-ACL error: permissions not set. Please set permissions on the homedir manually"
}

