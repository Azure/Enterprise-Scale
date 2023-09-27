# ALZ Policy Testing Workflow Sample

``` YAML
name: ALZ Tests for Policy

on:
  pull_request:
    types:
      - opened
      - reopened
      - synchronize
      - ready_for_review
    branches:
      - main
      - TestingFramework # For testing purposes only update as needed based on branch name
    paths:
      - ".github/workflows/**"
      - "tests/policy/**"
      - "tests/utils/**"
  workflow_dispatch:
    inputs:
      remarks:
        description: "Reason for triggering the workflow run"
        required: false
        default: "Testing Azure Policies..."

jobs:
  test-alz-policies:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          ref: ${{ github.event.pull_request.head.sha }}
          persist-credentials: false

      - name: Install PowerShell modules
        shell: pwsh
        run: |
          Install-Module -Name "Az" -RequiredVersion "10.1.0" -Force -Scope CurrentUser -ErrorAction Stop
          Update-AzConfig -DisplayBreakingChangeWarning $false

      - name: Azure login (OIDC)
        uses: azure/login@v1
        if: ${{ success() && env.AZURE_CLIENT_SECRET == '' }}
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          enable-AzPSSession: true
        env:
          AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
  
      - name: Azure login (Client Secret)
        uses: azure/login@v1
        if: ${{ success() && env.AZURE_CLIENT_SECRET != '' }}
        with:
          creds: '{"clientId":"${{ secrets.AZURE_CLIENT_ID }}","clientSecret":"${{ secrets.AZURE_CLIENT_SECRET }}","subscriptionId":"${{ secrets.AZURE_SUBSCRIPTION_ID }}","tenantId":"${{ secrets.AZURE_TENANT_ID }}"}'
          enable-AzPSSession: true
        env:
          AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}          

      - name: Pester Test for Policies
        shell: pwsh
        run: |
          Import-Module Pester -Force
          $pesterConfiguration = @{
            Run    = @{
              Path = "tests/*.tests.ps1" 
              PassThru  = $true
            }
            Output = @{
              Verbosity = 'Detailed'
              CIFormat = 'Auto'
            }
          }
          $result = Invoke-Pester -Configuration $pesterConfiguration
          exit $result.FailedCount
        env:
          SUBSCRIPTION_ID: ${{ secrets.AZURE_POLICY_SUBSCRIPTION1_ID }}
          SUBSCRIPTION2_ID: ${{ secrets.AZURE_POLICY_SUBSCRIPTION2_ID }} #Used for policy tests that require a second subscription (e.g. cross subscription peering)
          TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
```