<#
.SYNOPSIS
This script contains a function to import required modules if they are not already imported.

.DESCRIPTION
The Import-ModulesIfNotExists function checks if the required modules are already imported. 
If any of the required modules are missing, it displays an error message and exits the script. Otherwise, it imports the remaining modules.

.PARAMETER ModuleNames
Specifies an array of module names that need to be imported.

.EXAMPLE
$RequiredModules = @('HPEOneView.850', 'Microsoft.PowerShell.Security', 'Microsoft.PowerShell.Utility')
Import-ModulesIfNotExists -ModuleNames $RequiredModules

This example imports the required modules specified in the $RequiredModules array using the Import-ModulesIfNotExists function.

.NOTES
Author: CHARCHOUF SABRI
Date:   14/03/2024
Version : 1.0
#>
function Import-ModulesIfNotExists {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ModuleNames
    )
    # Check for missing modules
    Write-Host "`tChecking for missing modules..." -ForegroundColor Cyan
    # Check if the required modules are already imported
    $missingModules = $ModuleNames | Where-Object { -not (Get-Module -Name $_ -ListAvailable) }
    # If there are missing modules, display a message and exit the script
    if ($missingModules) {
        Write-Host "`tCritical modules missing: " -NoNewline -ForegroundColor Red
        Write-Host "$($missingModules -join ', ')" -ForegroundColor Yellow
        Write-Host "`tThe script cannot continue without these missing module(s). Please ensure they are installed locally and try again." -ForegroundColor Red
        Exit 1  # Exit with error code 1
    }
    # Import remaining modules
    $totalModules = $ModuleNames.Count
    $currentModuleNumber = 0
    foreach ($ModuleName in $ModuleNames) {
        $currentModuleNumber++
        if (Get-Module -Name $ModuleName -ListAvailable) {
            Write-Host "`tThe module " -NoNewline -foregroundColor Yellow
            Write-Host "[$ModuleName] " -NoNewline -foregroundColor Cyan
            Write-Host "is already imported." -ForegroundColor Yellow
        } else {
            $progress = ($currentModuleNumber / $totalModules) * 100
            Write-Progress -Activity "Importing $ModuleName" -Status "Please wait..." -PercentComplete $progress
            Import-Module -Name $ModuleName -ErrorAction SilentlyContinue -ErrorVariable importError
            if ($importError) {
                Write-Host "`tFailed to import The module " -NoNewline -ForegroundColor Red
                Write-Host "$ModuleName $($importError.Exception.Message)" -ForegroundColor Red
            } else {
                Write-Host "`tSuccessfully imported The module" -NoNewline -ForegroundColor Green
                Write-Host "[$ModuleName]" -ForegroundColor Green
            }
        }
    }
    # Clear progress bar (optional)
    Write-Progress -Activity "Importing modules" -Completed
    Write-Host "`n`tDone checking and importing modules." -ForegroundColor Green
}
# Import the required modules
$RequiredModules = @('HPEOneView.850', 'Microsoft.PowerShell.Security', 'Microsoft.PowerShell.Utility')
Import-ModulesIfNotExists -ModuleNames $RequiredModules