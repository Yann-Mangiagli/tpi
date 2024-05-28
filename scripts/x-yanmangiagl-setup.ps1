<#
.NOTES
    Nom: x-yanmangiagl-setup.ps1
    Auteur: Yann Mangiagli
    Date de cr�ation: 15 mai 2024
    Date de modification 1 : 17 mai 2024
    Raison: Changement de commentaires + changements l�gers pour respecter les conventions
    Date de modification 2 : 24 mai 2024
    Raison: Debug pour faire appara�tre le chemin du script correctement dans les arguments
    + ajouts de try catch
    Date de modification 3 : 27 mai 2024
    Raison: Ajout de Write-Host pour dire que l'action a �t� r�alis�e

.SYNOPSIS
    Copie / colle un script et cr�e une t�che planifi�e

.DESCRIPTION
    Copie un script nomme � un chemin specifique et le colle dans un pc distant
    Cr�e une tache planifiee permettant de lancer le script install� plus t�t

.EXAMPLE
.\x-yanmangiagl-setup.ps1 -remoteip "192.168.10.51"

.EXAMPLE
.\x-yanmangiagl-setup.ps1 -remoteip "192.168.10.51","192.168.10.53"

.PARAMETER ComputerList
    Liste des ordinateurs sur lesquels le script effectuera la copie

.LINK
    https://github.com/Yann-Mangiagli/tpi/tree/main/scripts
#>

# Cr�e un param�tre tableau
param([string[]]$remoteip)

# Cr�ation tableau de maximum 10
$computerList= New-Object System.Collections.ArrayList(10)

#
if($remoteip -eq '')
{
    # Donne l'adresse de l'ordinateur local si aucune adresse ip n'est ajout�e.
    $remoteip = "127.0.0.1"

    # Convertit l'adresse IP en nom d'h�te
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

# Entr�e du mot de passe � utiliser dans les credentiels
$password = ConvertTo-SecureString(".Etml-123") -AsPlainText -Force

# Renseignement des cr�dentiels automatique
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist "Administrateur", $password

# Nom du script
$scriptName = "\x-yanmangiagl-monitoring.ps1"

# Instanciation des chemins
$startPath = $PSScriptRoot + $scriptName
$destinationPath = "C:\Scripts"

# V�rifie que la connexion peut �tre faite
try{
    foreach($computer in $computerList){
    # Connexion � ordinateur distant
    $remotename = [System.Net.Dns]::GetHostByAddress($computer).Hostname

    # Cr�ation d'une session
    $session = New-PSSession -ComputerName $remotename -Credential $credentials

    # V�rifie que le dossier Scripts existe
    Invoke-Command -Session $session -ScriptBlock{
    $folderExists = Test-Path -Path "C:\Scripts"
        if(!($folderExists)){
            New-Item -Path "C:\Scripts" -ItemType Directory
        }
    }

    # Copie depuis machine locale du fichier et colle sur la machine distante ou la liste d'ordinateur
    Copy-Item $startPath -Destination $destinationPath -ToSession $session
    Write-Host "Fichier copi� dans " $destinationPath

    Invoke-Command -Session $session -ScriptBlock {
       # Concatenation du chemin
       $fullpath = '-File ' + '"C:\Scripts\x-yanmangiagl-monitoring.ps1"'

       # V�rifie que la t�che existe pas et la supprime si elle existe
       $pathExists = Test-Path -Path "C:\Windows\System32\Tasks\MonitoringAuto4PM"
       if($pathExists){
       Remove-Item -Path "C:\Windows\System32\Tasks\MonitoringAuto4PM"
       }

       # Cr�ation de la t�che
       $task = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $fullpath
       $taskInterval = New-ScheduledTaskTrigger -Daily -At 4PM
       $taskName = "MonitoringAuto4PM"
       $taskDesc = "R�cup�re les donn�es d'un ordinateur, envoie des mails et supprime les fichiers trop volumineux"

       # Enregistrement de la tache
       Register-ScheduledTask -TaskName $taskName -Action $task -Trigger $taskInterval -Description $taskDesc

       Write-Host "T�che planifi�e cr��e"
    }
}
}catch{
    Write-Error "Au moins une adresse IP est incorrecte."
    Exit
}