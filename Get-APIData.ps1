[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if ($PSScriptRoot) {
    $scriptfolder = $PSScriptRoot
}
else {
    $scriptfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$apikey = get-content "$scriptfolder\..\rapidapikey.txt"

$headers = @{
    "x-rapidapi-host" = "coronavirus-monitor.p.rapidapi.com";
    "x-rapidapi-key"  = $apikey
}

$country = "new zealand"
$query = "?country=$([uri]::EscapeUriString($country))"
$usa_query = "?country=USA"
$uk_query = "?country=UK"
$latest_NZ_url = "https://coronavirus-monitor.p.rapidapi.com/coronavirus/latest_stat_by_country.php$query"
$cases_by_country_url = "https://coronavirus-monitor.p.rapidapi.com/coronavirus/cases_by_country.php"
$nz_history_url = "https://coronavirus-monitor.p.rapidapi.com/coronavirus/cases_by_particular_country.php$query"
$usa_history_url = "https://coronavirus-monitor.p.rapidapi.com/coronavirus/cases_by_particular_country.php$usa_query"
$uk_history_url = "https://coronavirus-monitor.p.rapidapi.com/coronavirus/cases_by_particular_country.php$uk_query"


$response_cases_by_country = (Invoke-RestMethod -Method Get -Uri $cases_by_country_url -Headers $headers).countries_stat
$response_latest_nz = (Invoke-RestMethod -Method Get -Uri $latest_NZ_url -Headers $headers).latest_stat_by_country
$response_nz_history = (Invoke-RestMethod -Method Get -Uri $nz_history_url -Headers $headers).stat_by_country
$response_usa_history = (Invoke-RestMethod -Method Get -Uri $usa_history_url -Headers $headers).stat_by_country
$response_uk_history = (Invoke-RestMethod -Method Get -Uri $uk_history_url -Headers $headers).stat_by_country

$response_nz_history | export-csv nz.csv -NoTypeInformation
$response_usa_history | export-csv usa.csv -NoTypeInformation
$response_uk_history | export-csv uk.csv -NoTypeInformation


$nz_by_date = $response_nz_history | Group-Object record_date_pure

for ($i = 0; $i -lt ($nz_by_date.count ); $i++) { 
    $nz_by_date[$i].Group | 
    Where-Object { $_.new_cases -ne '' } | 
    Select-Object record_date_pure, new_cases,total_cases,new_deaths,total_deaths -Last 1 | Format-Table 
}