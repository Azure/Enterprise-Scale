$GitHubUserName = "buttyx"
$GitHubPAT = "a9a9f5a17ed3c77f09c87e8b85208c5e2fb6f4b9"
$GitHubRepoName = "Enterprise-Scale"
$uri = "https://api.github.com/repos/$GitHubUserName/$GitHubRepoName/dispatches"
$params = @{
    Uri = $uri
    Headers = @{
        "Accept" = "application/vnd.github.everest-preview+json"
        "Content-Type" = "application/json"
        "Authorization" = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $GitHubUserName,$GitHubPAT))))"
        }
    Body = @{
        "event_type" = "activity-logs"
        } | ConvertTo-json
    }
Invoke-RestMethod -Method "POST" @params

# {
#     "clientId": "cad04536-3f6b-469f-8f5a-31a5180a903b",
#     "displayName": "AzOpsMain",
#     "name": "http://AzOpsMain",
#     "clientSecret": "e58020c6-6156-45de-9cfb-31b3c4839c68",
#     "tenantId": "150573ab-0109-4af3-848b-322e624df6a6",
#     "subscriptionId": "c38585b0-4438-478b-8ccf-febd433355ba"
#   }