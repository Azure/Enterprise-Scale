#!/usr/bin/pwsh

$ErrorActionPreference = "Stop"
# Set-StrictMode -Version 3.0

###########################
# Import module functions #
###########################

# Dot source all functions located in the module
# Excludes tests and profiles

$functions = @()
$functions += Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 -Exclude *.tests.ps1, *profile.ps1 -ErrorAction SilentlyContinue
$functions.foreach({
    try {
        Write-Verbose "Dot sourcing [$($_.FullName)]"
        . $_.FullName
    }
    catch {
        throw "Unable to dot source [$($_.FullName)]"
    }
})
