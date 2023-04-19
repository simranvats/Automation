$AzureDevOpsPAT = "zmro4qanko2sg3aheky2bl4syolda2cpu56chrcngjh27osvrdzq"
$OrganizationName = "TPGlobal-TAP"
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }
$UriOrga = "https://dev.azure.com/$($OrganizationName)/"
$uriAccount = $UriOrga + "_apis/projects?api-version=5.1"




$Projects = Invoke-RestMethod -Uri $uriAccount -Method get -Headers $AzureDevOpsAuthenicationHeader
$PrjData = $Projects.value | Select-object id, name

foreach ($id in $PrjData){
    $Pipelines = Invoke-RestMethod -Uri https://dev.azure.com/$OrganizationName/$id/_apis/pipelines?api-version=7.0 -Headers $AzureDevOpsAuthenicationHeader
    

    $Pipelines.value.name
}

