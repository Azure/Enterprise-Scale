# Parameter help description
param(
    [Parameter(Mandatory=$true, HelpMessage="Enter the ESLZ root name.")]
    [string]
    $eslzRootName

)

# Register Microsoft.Network resource provider with eslzRoot 
Invoke-AzRestMethod -Method POST -Uri "https://management.azure.com/providers/Microsoft.Management/managementGroups/$eslzRootName/providers/Microsoft.Network/register?api-version=2021-04-01"