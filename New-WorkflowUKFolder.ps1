<#
.SYNOPSIS
Script to create new folder in Z:\WorkflowUK and relevant R and RW groups

.DESCRIPTION
Script to automate new WorkflowUK folder creation. It will prompt for the folder name and owner

#>


#Ask for the folder name and owner

$FolderName = Read-Host "Folder name: "
$FolderOwner = Read-Host "Folder owner: "
$FullFolderPath = "Z:\WorkflowUK\" + $FolderName

$WorkflowUKPath = "Z:\WorkflowUK"

#Create R and RW groups: Access and Rights
#Group names: Access group is added to the Rights group, Rights group granted with Permissions
#Access.FS.WorkFlowUK.<FolderName>.Full
#Access.FS.WorkFlowUK.<FolderName>.Read
#Rights.FS.WorkFlowUK.<FolderName>.Full
#Rights.FS.WorkFlowUK.<FolderName>.Read

#Set the Groups names
$AccessGroupNameFull = "Access.FS.WorkFlowUK." + $FolderName + ".Full"
$AccessGroupNameRead = "Access.FS.WorkFlowUK." + $FolderName + ".Read"
$AccessGroupsADPath = "OU=File,OU=Access Groups,DC=corpdomain,DC=local"
$RightsGroupNameFull = "Rights.FS.WorkFlowUK." + $FolderName + ".Full"
$RightsGroupNameRead = "Rights.FS.WorkFlowUK." + $FolderName + ".Read"
$RightsGroupsADPath = "OU=File,OU=Resources groups,DC=corpdomain,DC=local"
$GroupsDescription = "Owner: " + $FolderOwner

Write-Output "Creating security groups"

#Create the groups and add Access groups to the Rights groups
$AccessGroupFull= New-ADGroup -Name $AccessGroupNameFull -SamAccountName $AccessGroupNameFull -GroupCategory Security -GroupScope Global -DisplayName $AccessGroupNameFull -Path $AccessGroupsADPath -Description $GroupsDescription -PassThru -Confirm
$AccessGroupRead= New-ADGroup -Name $AccessGroupNameRead -SamAccountName $AccessGroupNameRead -GroupCategory Security -GroupScope Global -DisplayName $AccessGroupNameRead -Path $AccessGroupsADPath -Description $GroupsDescription -PassThru -Confirm

$RightGroupFull = New-ADGroup -Name $RightsGroupNameFull -SamAccountName $RightsGroupNameFull -GroupCategory Security -GroupScope DomainLocal -DisplayName $RightsGroupNameFull -Path $RightsGroupsADPath -Description $GroupsDescription -PassThru -Confirm
$RightGroupRead = New-ADGroup -Name $RightsGroupNameRead -SamAccountName $RightsGroupNameRead -GroupCategory Security -GroupScope DomainLocal -DisplayName $RightsGroupNameRead -Path $RightsGroupsADPath -Description $GroupsDescription -PassThru -Confirm

Add-ADGroupMember -Identity $RightGroupFull -Members $AccessGroupFull
Add-ADGroupMember -Identity $RightGroupRead -Members $AccessGroupRead

Write-Output "Security Groups created"

#Create the folder and set permissions to the groups

Write-Output "Creating folder and setting permissions"
$CreatedFolder = New-Item -ItemType Directory -Path $FullFolderPath -Confirm

$FolderAcl = Get-Acl $CreatedFolder
$ReadAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($RightGroupRead.SID, "Read","ContainerInherit, ObjectInherit", "None", "Allow")
$FullAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($RightGroupFull.SID, "Modify","ContainerInherit, ObjectInherit", "None", "Allow")
$FolderAcl.AddAccessRule($ReadAccessRule)
$FolderAcl.AddAccessRule($FullAccessRule)
Set-Acl -Path $FullFolderPath -AclObject $FolderAcl

#also apply special permissions to WorkflowUK
#yet to be tested

#$WorkflowUKFolder = get-item -Path $WorkflowUKPath
#$WorkflowUKAcl = Get-Acl $WorkflowUKFolder
#$SpecialPermissionsReadGroup =New-Object System.Security.AccessControl.FileSystemAccessRule($RightGroupRead.SID, "ListDirectory", "ReadAttributes", "ReadExtendedAttributes" ,"ContainerInherit, ObjectInherit", "None", "Allow")
#$SpecialPermissionsFullGroup =New-Object System.Security.AccessControl.FileSystemAccessRule($RightGroupFull.SID,"ListDirectory", "ReadAttributes", "ReadExtendedAttributes","ContainerInherit, ObjectInherit", "None", "Allow")
#$WorkflowUKAcl.AddAccessRule($SpecialPermissionsReadGroup)
#$WorkflowUKAcl.AddAccessRule($SpecialPermissionsFullGroup)
#Set-Acl -Path $WorkflowUKPath -AclObject $WorkflowUKAcl


Write-Output "Folder created and permissions set"