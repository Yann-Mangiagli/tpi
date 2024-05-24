# Crée un paramètre tableau
param([string[]]$remoteip)

#Création tableau
$computerList= New-Object System.Collections.ArrayList

# Pour chaque IP dans $args, ajoute
foreach($computerIP in $remoteip){
    $computerList.Add($computerIP) | Out-Null
    Write-Host "Ajouté : "  $computerIP
}

foreach($computer in $computerList){
    Write-Host "Dans computer" $computer
}
$PSScriptRootT = $PSScriptRoot
Write-Host $PSScriptRootT
$zouz = (Get-Item  $PSScriptRootT).Parent.Parent.Parent.Parent
Write-Host = $zouz