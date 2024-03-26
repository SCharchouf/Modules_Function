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
#># Assuming the Logging folder is at the same level as the Scripts folder
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loggingFunctionsPath = Join-Path -Path $scriptPath -ChildPath "..\Logging\Logging_Functions.ps1"

# Source the logging functions
. $loggingFunctionsPath

# Define the function to import modules if they are not already present
function Import-ModulesIfNotExists {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ModuleNames
    )
    # Check for missing modules
    Write-Log "`tChecking for missing modules..." -ForegroundColor Cyan
    # Check if the required modules are already imported
    $missingModules = $ModuleNames | Where-Object { -not (Get-Module -Name $_ -ListAvailable) }
    # If there are missing modules, display a message and exit the script
    if ($missingModules) {
        Write-Log "`tCritical modules missing: " -NoNewline -ForegroundColor Red
        Write-Log "$($missingModules -join ', ')" -ForegroundColor Yellow
        Write-Log "`tThe script cannot continue without these missing module(s). Please ensure they are installed locally and try again." -ForegroundColor Red
        Exit 1  # Exit with error code 1
    }
    # Import remaining modules
    $totalModules = $ModuleNames.Count
    $currentModuleNumber = 0
    foreach ($ModuleName in $ModuleNames) {
        $currentModuleNumber++
        if (Get-Module -Name $ModuleName -ListAvailable) {
            Write-Log "`tThe module " -NoNewline -foregroundColor Yellow
            Write-Log "[$ModuleName] " -NoNewline -foregroundColor Cyan
            Write-Log "is already imported." -ForegroundColor Yellow
        } else {
            $progress = ($currentModuleNumber / $totalModules) * 100
            Write-Progress -Activity "Importing $ModuleName" -Status "Please wait..." -PercentComplete $progress
            Import-Module -Name $ModuleName -ErrorAction SilentlyContinue -ErrorVariable importError
            if ($importError) {
                Write-Log "`tFailed to import The module " -NoNewline -ForegroundColor Red
                Write-Log "$ModuleName $($importError.Exception.Message)" -ForegroundColor Red
            } else {
                Write-Log "`tSuccessfully imported The module" -NoNewline -ForegroundColor Green
                Write-Log "[$ModuleName]" -ForegroundColor Green
            }
        }
    }
    # Clear progress bar (optional)
    Write-Progress -Activity "Importing modules" -Completed
    Write-Log "`n`tDone checking and importing modules." -ForegroundColor Green
}

# Import the required modules
$RequiredModules = @('HPEOneView.850', 'Microsoft.PowerShell.Security', 'Microsoft.PowerShell.Utility')
Import-ModulesIfNotExists -ModuleNames $RequiredModules

# Now you can use logging functions like Write-Log and the imported modules

