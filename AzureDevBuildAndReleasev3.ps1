#PAT
$AzureDevOpsPAT = ""

#Organisation Name
$OrganizationName = "TPGlobal-TAP"

#Authentication
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }
$UriOrga = "https://dev.azure.com/$($OrganizationName)/"
$uriAccount = $UriOrga + "_apis/projects?api-version=5.1"

#Getting Projects
$Projects = Invoke-RestMethod -Uri $uriAccount -Method get -Headers $AzureDevOpsAuthenicationHeader
$PrjData = $Projects.value | Select-object id, name

# Array to store Data
$Results = @()

# Looping through each project
foreach ($id in $PrjData) {
    $PrjID = $id.id
    $PrjDes = Invoke-RestMethod -Uri https://vssps.dev.azure.com/$OrganizationName/_apis/graph/descriptors/$PrjID -Headers $AzureDevOpsAuthenicationHeader
    $ScpHash = $PrjDes.value
    $ScpDes = Invoke-RestMethod -Uri https://vssps.dev.azure.com/$OrganizationName/_apis/graph/groups?scopeDescriptor=$ScpHash -Headers $AzureDevOpsAuthenicationHeader
    $TeamID = $ScpDes.value | Where-Object { $_.displayName -eq "Project Administrators" }
    $orig = $TeamID.originId
    $data = Invoke-RestMethod -Uri https://vsaex.dev.azure.com/$OrganizationName/_apis/GroupEntitlements/$orig/members -Headers $AzureDevOpsAuthenicationHeader
    $admins = $data.members.user.principalname -join ","
 
    # Fetching Release pipeline
    $ReleasePipelines = Invoke-RestMethod -Uri https://vsrm.dev.azure.com/$OrganizationName/$PrjID/_apis/release/releases?api-version=7.0 -Headers $AzureDevOpsAuthenicationHeader
    $ReleasePipeline = $ReleasePipelines.value

    # Iterating through  each release pipeline
    foreach ($pipeline in $ReleasePipeline) {
        $item = New-Object PSObject
        $item | Add-Member -Type NoteProperty -Name "Organisation Name" -Value $OrganizationName
        $item | Add-Member -Type NoteProperty -Name "Project Name" -Value $id.name
        $item | Add-Member -Type NoteProperty -Name "Owners" -Value $admins
        $item | Add-Member -Type NoteProperty -Name "Pipeline Name" -Value $pipeline.releaseDefinition.name
        $item | Add-Member -Type NoteProperty -Name "Pipeline Type" -Value "Release"
        $item | Add-Member -Type NoteProperty -Name "Pool Name" -Value "NOT Found For now"
        $Results += $item
    }

    # Fetching Build pipeline
    $BuildPipelines = Invoke-RestMethod -Uri https://dev.azure.com/$OrganizationName/$PrjID/_apis/build/builds?api-version=7.0 -Headers $AzureDevOpsAuthenicationHeader
    $Buildpipeline = $BuildPipelines.value

    # Iterating through  each build pipeline
    foreach ($pipeline in $Buildpipeline) {
        $item = New-Object PSObject
        $item | Add-Member -Type NoteProperty -Name "Organisation Name" -Value $OrganizationName
        $item | Add-Member -Type NoteProperty -Name "Project Name" -Value $id.name
        $item | Add-Member -Type NoteProperty -Name "Owners" -Value $admins
        $item | Add-Member -Type NoteProperty -Name "Pipeline Name" -Value $pipeline.definition.name
        $item | Add-Member -Type NoteProperty -Name "Pipeline Type" -Value "Build"
        $item | Add-Member -Type NoteProperty -Name "Pool name" -Value $pipeline.queue.name
        $Results += $item  
    }
}

# Grouping the data by the properties that we want to use as unique identifiers
$groupedData = $Results  | Group-Object -Property 'Pipeline Name'

# Selecting the first item from each group to remove duplicates
$uniqueData = $groupedData | ForEach-Object { $_.Group[0] }

# Exporting the unique data to a new CSV file
$uniqueData | Export-Csv -Path 'C:\Users\madhuker.5\Desktop\FinalFile.csv' -NoTypeInformation

# Opening the file after exporting
Start-Process -FilePath "C:\Users\madhuker.5\Desktop\FinalFile.csv" 
