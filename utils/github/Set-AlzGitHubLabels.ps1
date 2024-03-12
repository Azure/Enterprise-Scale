[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Coloured output required in this script")]

<#
.SYNOPSIS
  This script can be used to create the Azure Landing Zones (ALZ) standard GitHub labels to a GitHub repository.

.DESCRIPTION
  This script can be used to create the Azure Landing Zones (ALZ) standard GitHub labels to a GitHub repository.

  By default, the script will remove all pre-existing labels and apply the ALZ labels. However, this can be changed by using the -RemoveExistingLabels parameter and setting it to $false. The tool will also output the labels that exist in the repository before and after the script has run to a CSV file in the current directory, or a directory specified by the -OutputDirectory parameter.

  The ALZ labels to be created are documented here: TBC

.NOTES
  Please ensure you have specified the GitHub repositry correctly. The script will prompt you to confirm the repository name before proceeding.

.COMPONENT
  You must have the GitHub CLI installed and be authenticated to a GitHub account with access to the repository you are applying the labels to before running this script.

.LINK
  TBC

.Parameter RepositoryName
  The name of the GitHub repository to apply the labels to.

.Parameter RemoveExistingLabels
  If set to $true, the default value, the script will remove all pre-existing labels from the repository specified in -RepositoryName before applying the ALZ labels. If set to $false, the script will not remove any pre-existing labels.

.Parameter UpdateAndAddLabelsOnly
  If set to $true, the default value, the script will only update and add labels to the repository specified in -RepositoryName. If set to $false, the script will remove all pre-existing labels from the repository specified in -RepositoryName before applying the ALZ labels.

.Parameter OutputDirectory
  The directory to output the pre-existing and post-existing labels to in a CSV file. The default value is the current directory.

.Parameter CreateCsvLabelExports
  If set to $true, the default value, the script will output the pre-existing and post-existing labels to a CSV file in the current directory, or a directory specified by the -OutputDirectory parameter. If set to $false, the script will not output the pre-existing and post-existing labels to a CSV file.

.Parameter GitHubCliLimit
  The maximum number of labels to return from the GitHub CLI. The default value is 999.

.Parameter LabelsToApplyCsvUri
  The URI to the CSV file containing the labels to apply to the GitHub repository. The default value is https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/utils/github/alz-repo-standard-labels.csv.

.Parameter NoUserPrompts
  If set to $true, the default value, the script will not prompt the user to confirm they want to remove all pre-existing labels from the repository specified in -RepositoryName before applying the ALZ labels. If set to $false, the script will prompt the user to confirm they want to remove all pre-existing labels from the repository specified in -RepositoryName before applying the ALZ labels.

  This is useful for running the script in automation workflows

.EXAMPLE
  Create the ALZ labels in the repository Org/MyGitHubRepo and remove all pre-existing labels.

  Set-AlzGitHubLabels.ps1 -RepositoryName "Org/MyGitHubRepo"

.EXAMPLE
  Create the ALZ labels in the repository Org/MyGitHubRepo and do not remove any pre-existing labels, just overwrite any labels that have the same name.

  Set-AlzGitHubLabels.ps1 -RepositoryName "Org/MyGitHubRepo" -RemoveExistingLabels $false

.EXAMPLE
  Create the ALZ labels in the repository Org/MyGitHubRepo and output the pre-existing and post-existing labels to the directory C:\GitHubLabels.

  Set-AlzGitHubLabels.ps1 -RepositoryName "Org/MyGitHubRepo" -OutputDirectory "C:\GitHubLabels"

.EXAMPLE
  Create the ALZ labels in the repository Org/MyGitHubRepo and output the pre-existing and post-existing labels to the directory C:\GitHubLabels and do not remove any pre-existing labels, just overwrite any labels that have the same name.

  Set-AlzGitHubLabels.ps1 -RepositoryName "Org/MyGitHubRepo" -OutputDirectory "C:\GitHubLabels" -RemoveExistingLabels $false

.EXAMPLE
  Create the ALZ labels in the repository Org/MyGitHubRepo and do not create the pre-existing and post-existing labels CSV files and do not remove any pre-existing labels, just overwrite any labels that have the same name.

  Set-AlzGitHubLabels.ps1 -RepositoryName "Org/MyGitHubRepo" -RemoveExistingLabels $false -CreateCsvLabelExports $false

.EXAMPLE
  Create the ALZ labels in the repository Org/MyGitHubRepo and do not create the pre-existing and post-existing labels CSV files and do not remove any pre-existing labels, just overwrite any labels that have the same name. Finally, use a custom CSV file hosted on the internet to create the labels from.

  Set-AlzGitHubLabels.ps1 -RepositoryName "Org/MyGitHubRepo" -OutputDirectory "C:\GitHubLabels" -RemoveExistingLabels $false -CreateCsvLabelExports $false -LabelsToApplyCsvUri "https://example.com/csv/alz-github-labels.csv"

#>

#Requires -PSEdition Core

[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)]
  [string]$RepositoryName,

  [Parameter(Mandatory = $false)]
  [bool]$RemoveExistingLabels = $true,

  [Parameter(Mandatory = $false)]
  [bool]$UpdateAndAddLabelsOnly = $true,

  [Parameter(Mandatory = $false)]
  [bool]$CreateCsvLabelExports = $true,

  [Parameter(Mandatory = $false)]
  [string]$OutputDirectory = (Get-Location),

  [Parameter(Mandatory = $false)]
  [int]$GitHubCliLimit = 999,

  [Parameter(Mandatory = $false)]
  [string]$LabelsToApplyCsvUri = "https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/utils/github/alz-repo-standard-labels.csv",

  [Parameter(Mandatory = $false)]
  [bool]$NoUserPrompts = $false
)

# Check if the GitHub CLI is installed
$GitHubCliInstalled = Get-Command gh -ErrorAction SilentlyContinue
if ($null -eq $GitHubCliInstalled) {
  throw "The GitHub CLI is not installed. Please install the GitHub CLI and try again."
}
Write-Host "The GitHub CLI is installed..." -ForegroundColor Green

# Check if GitHub CLI is authenticated
$GitHubCliAuthenticated = gh auth status
if ($null -eq $GitHubCliAuthenticated) {
  throw "Not authenticated to GitHub. Please authenticate to GitHub using the GitHub CLI, `gh auth login`, and try again."
}
Write-Host "Authenticated to GitHub..." -ForegroundColor Green

# Check if GitHub repository name is valid
$GitHubRepositoryNameValid = $RepositoryName -match "^[a-zA-Z0-9-]+/[a-zA-Z0-9-]+$"
if ($false -eq $GitHubRepositoryNameValid) {
  throw "The GitHub repository name $RepositoryName is not valid. Please check the repository name and try again. The format must be <OrgName>/<RepoName>"
}

# List GitHub repository provided and check it exists
$GitHubRepository = gh repo view $RepositoryName
if ($null -eq $GitHubRepository) {
  throw "The GitHub repository $RepositoryName does not exist. Please check the repository name and try again."
}
Write-Host "The GitHub repository $RepositoryName exists..." -ForegroundColor Green

# PRE - Get the current GitHub repository labels and export to a CSV file in the current directory or where -OutputDirectory specifies if set to a valid directory path and the directory exists or can be created if it does not exist already
if ($RemoveExistingLabels -or $UpdateAndAddLabelsOnly) {
  Write-Host "Getting the current GitHub repository (pre) labels for $RepositoryName..." -ForegroundColor Yellow
  $GitHubRepositoryLabels = gh label list -R $RepositoryName -L $GitHubCliLimit --json name,description,color

  if ($null -ne $GitHubRepositoryLabels -and $CreateCsvLabelExports -eq $true) {
    $csvFileNamePathPre = "$OutputDirectory\$($RepositoryName.Replace('/', '_'))-Labels-Pre-$(Get-Date -Format FileDateTime).csv"
    Write-Host "Exporting the current GitHub repository (pre) labels for $RepositoryName to $csvFileNamePathPre" -ForegroundColor Yellow
    $GitHubRepositoryLabels | ConvertFrom-Json | Export-Csv -Path $csvFileNamePathPre -NoTypeInformation
  }
}

# Remove all pre-existing labels if -RemoveExistingLabels is set to $true and user confirms they want to remove all pre-existing labels
if ($null -ne $GitHubRepositoryLabels) {
  $GitHubRepositoryLabelsJson = $GitHubRepositoryLabels | ConvertFrom-Json
  if ($RemoveExistingLabels -eq $true -and $NoUserPrompts -eq $false -and $UpdateAndAddLabelsOnly -eq $false) {
    $RemoveExistingLabelsConfirmation = Read-Host "Are you sure you want to remove all $($GitHubRepositoryLabelsJson.Count) pre-existing labels from $($RepositoryName)? (Y/N)"
    if ($RemoveExistingLabelsConfirmation -eq "Y") {
      Write-Host "Removing all pre-existing labels from $RepositoryName..." -ForegroundColor Yellow
      $GitHubRepositoryLabels | ConvertFrom-Json | ForEach-Object {
        Write-Host "Removing label $($_.name) from $RepositoryName..." -ForegroundColor DarkRed
        gh label delete -R $RepositoryName $_.name --yes
      }
    }
  }
  if ($RemoveExistingLabels -eq $true -and $NoUserPrompts -eq $true -and $UpdateAndAddLabelsOnly -eq $false) {
    Write-Host "Removing all pre-existing labels from $RepositoryName..." -ForegroundColor Yellow
    $GitHubRepositoryLabels | ConvertFrom-Json | ForEach-Object {
      Write-Host "Removing label $($_.name) from $RepositoryName..." -ForegroundColor DarkRed
      gh label delete -R $RepositoryName $_.name --yes
    }
  }
}
if ($null -eq $GitHubRepositoryLabels) {
  Write-Host "No pre-existing labels to remove or not selected to be removed from $RepositoryName..." -ForegroundColor Magenta
}

# Check LabelsToApplyCsvUri is valid and contains a CSV content
Write-Host "Checking $LabelsToApplyCsvUri is valid..." -ForegroundColor Yellow
$LabelsToApplyCsvUriValid = $LabelsToApplyCsvUri -match "^https?://"
if ($false -eq $LabelsToApplyCsvUriValid) {
  throw "The LabelsToApplyCsvUri $LabelsToApplyCsvUri is not valid. Please check the URI and try again. The format must be a valid URI."
}
Write-Host "The LabelsToApplyCsvUri $LabelsToApplyCsvUri is valid..." -ForegroundColor Green

# Create ALZ lables from the ALZ labels CSV file stored on the web using the convertfrom-csv cmdlet
$alzLabelsCsv = Invoke-WebRequest -Uri $LabelsToApplyCsvUri | ConvertFrom-Csv

# Check if the ALZ labels CSV file contains the following columns: Name, Description, HEX
$alzLabelsCsvColumns = $alzLabelsCsv | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
$alzLabelsCsvColumnsValid = $alzLabelsCsvColumns -contains "Name" -and $alzLabelsCsvColumns -contains "Description" -and $alzLabelsCsvColumns -contains "HEX"
if ($false -eq $alzLabelsCsvColumnsValid) {
  throw "The labels CSV file does not contain the required columns: Name, Description, HEX. Please check the CSV file and try again. It contains the following columns: $alzLabelsCsvColumns"
}
Write-Host "The labels CSV file contains the required columns: Name, Description, HEX" -ForegroundColor Green

# Create the ALZ labels in the GitHub repository
Write-Host "Creating/Updating the $($alzLabelsCsv.Count) ALZ labels in $RepositoryName..." -ForegroundColor Yellow
$alzLabelsCsv | ForEach-Object {
  if ($GitHubRepositoryLabelsJson.name -contains $_.name) {
    Write-Host "The label $($_.name) already exists in $RepositoryName. Updating the label to ensure description and color are consitent..." -ForegroundColor Magenta
    gh label create -R $RepositoryName "$($_.name)" -c $_.HEX -d $($_.Description) --force
  }
  else {
    Write-Host "The label $($_.name) does not exist in $RepositoryName. Creating label $($_.name) in $RepositoryName..." -ForegroundColor Cyan
    gh label create -R $RepositoryName "$($_.Name)" -c $_.HEX -d $($_.Description) --force
  }
}

# POST - Get the current GitHub repository labels and export to a CSV file in the current directory or where -OutputDirectory specifies if set to a valid directory path and the directory exists or can be created if it does not exist already
if ($CreateCsvLabelExports -eq $true) {
  Write-Host "Getting the current GitHub repository (post) labels for $RepositoryName..." -ForegroundColor Yellow
  $GitHubRepositoryLabels = gh label list -R $RepositoryName -L $GitHubCliLimit --json name,description,color

  if ($null -ne $GitHubRepositoryLabels) {
    $csvFileNamePathPre = "$OutputDirectory\$($RepositoryName.Replace('/', '_'))-Labels-Post-$(Get-Date -Format FileDateTime).csv"
    Write-Host "Exporting the current GitHub repository (post) labels for $RepositoryName to $csvFileNamePathPre" -ForegroundColor Yellow
    $GitHubRepositoryLabels | ConvertFrom-Json | Export-Csv -Path $csvFileNamePathPre -NoTypeInformation
  }
}

# If -RemoveExistingLabels is set to $true and user confirms they want to remove all pre-existing labels check that only the alz labels exist in the repository
if ($RemoveExistingLabels -eq $true -and ($RemoveExistingLabelsConfirmation -eq "Y" -or $NoUserPrompts -eq $true) -and $UpdateAndAddLabelsOnly -eq $false) {
  Write-Host "Checking that only the ALZ labels exist in $RepositoryName..." -ForegroundColor Yellow
  $GitHubRepositoryLabels = gh label list -R $RepositoryName -L $GitHubCliLimit --json name,description,color
  $GitHubRepositoryLabels | ConvertFrom-Json | ForEach-Object {
    if ($alzLabelsCsv.Name -notcontains $_.name) {
      throw "The label $($_.name) exists in $RepositoryName but is not in the CSV file."
    }
  }
  Write-Host "Only the CSV labels exist in $RepositoryName..." -ForegroundColor Green
}

Write-Host "The CSV labels have been created/updated in $RepositoryName..." -ForegroundColor Green
