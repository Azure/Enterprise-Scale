# Enterprise-Scale "in-a-box" troubleshooting

## Deploy resource specified in DINE policies

Once policy assignment are deployed, the platform will evaluate compliance state. This will take some time (from minutes up to multiple hours) once the compliance state is evaluated you can remediate out of compliance resources via portal.

For this hands-on guide or if this process needs to be kickstart run the following command:

`New-AzManagementGroupDeployment -ManagementGroupId '<managementGroupID>' -Location '<deployment-region>' -TemplateParameterFile '<managementGroup>.parameters.json' -TemplateUri 'https://raw.githubusercontent.com/Azure/AzOps/main/template/template.json'`

Here an example to start a deployment on `ES-management` management group scope used in this ES "in-a-box" guide:

`New-AzManagementGroupDeployment -ManagementGroupId 'ES-management' -Location 'northeurope' -TemplateParameterFile '.\azops\Tenant Root Group (<tenantID>)\ES (ES)\ES-platform (ES-platform)\ES-management (ES-management)\.AzState\Microsoft.Management_managementGroups-ES-management.parameters.json' -TemplateUri 'https://raw.githubusercontent.com/Azure/AzOps/main/template/template.json'`

This command is going to take some time to complete. Once this command completes, confirm that the resources are deployed.

## Deployment Region

If you are using AAD Tenant where you have previously deployed Enterprise-Scale and wish to use a region other than the one you used in your previous deployment, we highly recommend to clean up your previous Enterprise-Scale deployments. This is one-off time activity to ensure there are no conflicts.

Please use following snippet to clear all deployments at tenant, Management Group and Subscription scopes.

```PowerShell
Get-AzTenantDeployment   | Foreach-Object -Parallel {
    Write-Verbose "$(Get-Date) Removing Tenant Deployment $($_.Id)"
    Stop-AzTenantDeployment -Id $_.Id -Confirm:$false -ErrorAction:SilentlyContinue
    Remove-AzTenantDeployment -Id $_.Id
}

Get-AzManagementGroup   | Foreach-Object -Parallel {
    Get-AzManagementGroupDeployment -ManagementGroupId $_.Name |  Foreach-Object -Parallel {
        Write-Verbose "$(Get-Date) Removing Management Group Deployment $($_.Id)"
        Stop-AzManagementGroupDeployment -Id $_.Id -Confirm:$false -ErrorAction:SilentlyContinue
        Remove-AzManagementGroupDeployment -Id $_.Id
    }
}

Get-AzSubscription | ForEach-Object {
    Set-AzContext -SubscriptionId $_.SubscriptionId | out-null
    Get-AzSubscriptionDeployment |  Foreach-Object -Parallel {
        Write-Verbose "$(Get-Date) Removing Subscription Deployment $($_.Id)"
        Stop-AzSubscriptionDeployment -Id $_.Id -Confirm:$false -ErrorAction:SilentlyContinue
        Remove-AzSubscriptionDeployment -Id $_.Id
    }
}
```
