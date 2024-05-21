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