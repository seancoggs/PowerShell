<#
.SYNOPSIS
Import all GPOs in this baseline package (in \GPOs subdirectory) into Active Directory Group Policy
#>

# Identify all the directories/paths
$RootDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
$ParentDir = [System.IO.Path]::GetDirectoryName($RootDir)
$GPOsDir = [System.IO.Path]::Combine($ParentDir, "GPOs")

Write-Host "Importing the following GPOs:" -ForegroundColor Cyan
Write-Host
$GpoMap = New-Object System.Collections.SortedList
Get-ChildItem -Recurse -Include backup.xml $GPOsDir | ForEach-Object {
    $guid = $_.Directory.Name
    $displayName = ([xml](gc $_)).GroupPolicyBackupScheme.GroupPolicyObject.GroupPolicyCoreSettings.DisplayName.InnerText
    $GpoMap.Add($displayName, $guid)
}
$GpoMap.Keys | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
Write-Host
Write-Host


$GpoMap.Keys | ForEach-Object {
    $key = $_
    $guid = $GpoMap[$key]
    Write-Host ($guid + ": " + $key) -ForegroundColor Cyan
    Import-GPO -BackupId $guid -Path $GPOsDir -TargetName "$key" -CreateIfNeeded 
}
# SIG # Begin signature block