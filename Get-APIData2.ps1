[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if ($PSScriptRoot) {
    $scriptfolder = $PSScriptRoot
}
else {
    $scriptfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$apikey = get-content "$scriptfolder\..\rapidapikey.txt"

$headers = @{
    "x-rapidapi-host" = "covid-193.p.rapidapi.com";
	"x-rapidapi-key" = $apikey
}

$report = @()

$countries = @(
    "new-zealand",
    "usa"
)
foreach ($country in $countries) {

$history = "https://covid-193.p.rapidapi.com/history?country=$country"
$response = Invoke-RestMethod -Method Get -Uri $history -Headers $headers

$report += $response
}

