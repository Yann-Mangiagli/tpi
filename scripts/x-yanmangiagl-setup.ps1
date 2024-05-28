<#
.NOTES
    Nom: x-yanmangiagl-setup.ps1
    Auteur: Yann Mangiagli
    Date de création: 15 mai 2024
    Date de modification 1 : 17 mai 2024
    Raison: Changement de commentaires + changements légers pour respecter les conventions
    Date de modification 2 : 24 mai 2024
    Raison: Debug pour faire apparaître le chemin du script correctement dans les arguments
    + ajouts de try catch
    Date de modification 3 : 27 mai 2024
    Raison: Ajout de Write-Host pour dire que l'action a été réalisée

.SYNOPSIS
    Copie / colle un script et crée une tâche planifiée

.DESCRIPTION
    Copie un script nomme à un chemin specifique et le colle dans un pc distant
    Crée une tache planifiee permettant de lancer le script installé plus tôt

.EXAMPLE
.\x-yanmangiagl-setup.ps1 -remoteip "192.168.10.51"

.EXAMPLE
.\x-yanmangiagl-setup.ps1 -remoteip "192.168.10.51","192.168.10.53"

.PARAMETER ComputerList
    Liste des ordinateurs sur lesquels le script effectuera la copie

.LINK
    https://github.com/Yann-Mangiagli/tpi/tree/main/scripts
#>

# Crée un paramètre tableau
param([string[]]$remoteip)

# Création tableau de maximum 10
$computerList= New-Object System.Collections.ArrayList(10)

#
if($remoteip -eq '')
{
    # Donne l'adresse de l'ordinateur local si aucune adresse ip n'est ajoutée.
    $remoteip = "127.0.0.1"

    # Convertit l'adresse IP en nom d'hôte
    $remotename = [System.Net.Dns]::GetHostByAddress($remoteip).Hostname
}

if($remoteip.Count -le 10){
       # Ajout de tous les ordinateurs dans le tableau
   foreach($computerip in $remoteip)
   {
       $computerList.Add($computerip) | Out-Null
   }
}else{
        Write-Error "Maximum 10 adresses"
        }

# Entrée du mot de passe à utiliser dans les credentiels
$password = ConvertTo-SecureString(".Etml-123") -AsPlainText -Force

# Renseignement des crédentiels automatique
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist "Administrateur", $password

# Nom du script
$scriptName = "\x-yanmangiagl-monitoring.ps1"

# Instanciation des chemins
$startPath = $PSScriptRoot + $scriptName
$destinationPath = "C:\Scripts"

# Vérifie que la connexion peut être faite
try{
    foreach($computer in $computerList){
    # Connexion à ordinateur distant
    $remotename = [System.Net.Dns]::GetHostByAddress($computer).Hostname

    # Création d'une session
    $session = New-PSSession -ComputerName $remotename -Credential $credentials

    # Vérifie que le dossier Scripts existe
    Invoke-Command -Session $session -ScriptBlock{
    $folderExists = Test-Path -Path "C:\Scripts"
        if(!($folderExists)){
            New-Item -Path "C:\Scripts" -ItemType Directory
        }
    }

    # Copie depuis machine locale du fichier et colle sur la machine distante ou la liste d'ordinateur
    Copy-Item $startPath -Destination $destinationPath -ToSession $session
    Write-Host "Fichier copié dans " $destinationPath

    Invoke-Command -Session $session -ScriptBlock {
       # Concatenation du chemin
       $fullpath = '-File ' + '"C:\Scripts\x-yanmangiagl-monitoring.ps1"'

       # Vérifie que la tâche existe pas et la supprime si elle existe
       $pathExists = Test-Path -Path "C:\Windows\System32\Tasks\MonitoringAuto4PM"
       if($pathExists){
       Remove-Item -Path "C:\Windows\System32\Tasks\MonitoringAuto4PM"
       }

       # Création de la tâche
       $task = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $fullpath
       $taskInterval = New-ScheduledTaskTrigger -Daily -At 4PM
       $taskName = "MonitoringAuto4PM"
       $taskDesc = "Récupère les données d'un ordinateur, envoie des mails et supprime les fichiers trop volumineux"

       # Enregistrement de la tache
       Register-ScheduledTask -TaskName $taskName -Action $task -Trigger $taskInterval -Description $taskDesc

       Write-Host "Tâche planifiée créée"
    }
}
}catch{
    Write-Error "Au moins une adresse IP est incorrecte."
    Exit
}