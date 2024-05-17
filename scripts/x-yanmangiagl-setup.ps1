<#
.NOTES
    Nom: x-yanmangiagl-setup.ps1
    Auteur: Yann Mangiagli
    Date de création: 15 mai 2024
    Date de modification 1 : 17 mai 2024
    Raison: Changement de commentaires + changements légers pour respecter les conventions


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

# Ajout de tous les ordinateurs dans le tableau
foreach($computerip in $remoteip){
    $computerList.Add($computerip) | Out-Null
}

# Entrée du mot de passe à utiliser dans les credentiels
$password = ConvertTo-SecureString(".Etml-123") -AsPlainText -Force

# Renseignement des crédentiels automatique
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist "Administrateur", $password

# Instanciation des chemins /!\ à changer après
$startPath = "D:\FIN22-24\FIN2\00-TPI\tpi\scripts\x-yanmangiagl-monitoring.ps1"
$destinationPath = "C:\Scripts"

foreach($computer in $computerList){
    # Connexion à ordinateur distant
    $remotename = [System.Net.Dns]::GetHostByAddress($computer).Hostname

    # Création d'une session
    $session = New-PSSession -ComputerName $remotename -Credential $credentials

    # Copie depuis machine locale du fichier et colle sur la machine distante ou la liste d'ordinateur
    Copy-Item $startPath -Destination $destinationPath -ToSession $session

    Invoke-Command -Session $session -ScriptBlock {
       # Concatenation du chemin
       $fullpath = $destinationPath + '\x-yanmangiagl-monitoring.ps1'

       # Creation d'une tâche planifiee
       $task = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $fullpath
       $taskInterval = New-ScheduledTaskTrigger -Daily -At 4PM
       $taskName = "MonitoringAuto4PM"
       $taskDesc = "Récupère les données d'un ordinateur, envoie des mails et supprime les fichiers trop volumineux"

       # Enregistrement de la tache
       Register-ScheduledTask -TaskName $taskName -Action $task -Trigger $taskInterval -Description $taskDesc
    }
}