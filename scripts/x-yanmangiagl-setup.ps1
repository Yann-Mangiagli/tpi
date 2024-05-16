<#
.NOTES
    Nom: x-yanmangiagl-setup.ps1
    Auteur: Yann Mangiagli
    Date de cr�ation: 15 mai 2024
    Date de modification 1 : 16 mai 2024
    Raison: Ajout de fonctionnalit�s


.SYNOPSIS
    Copie / colle un script et cree une t�che planifi�e

.DESCRIPTION
    Copie un script nomme � un chemin specifique et le colle dans un pc distant
    Cr�e une tache planifiee permettant de lancer le script installe plus t�t

.EXAMPLE
.\x-yanmangiagl-setup.ps1 -ComputerList "yann2k22srv"

.EXAMPLE
.\x-yanmangiagl-setup.ps1 -ComputerList "yann2k22srv","yann2k22srv2"

.PARAMETER ComputerList
    Liste des ordinateurs sur lesquels le script effectuera la copie

.LINK
    https://github.com/Yann-Mangiagli/tpi/tree/main/scripts
#>

# Cree un param�tre tableau
param([string[]]$remoteip)

# Creation tableau
$computerList= New-Object System.Collections.ArrayList(10)

# Ajout de tous les ordinateurs dans le tableau
foreach($computerIP in $remoteip){
    $computerList.Add($computerIP) | Out-Null
}

# Entr�e du mot de passe � utiliser dans les credentiels
$password = ConvertTo-SecureString(".Etml-123") -AsPlainText -Force

# Renseignement des credentiels automatique
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist "Administrateur", $password

# Instanciation des chemins (start path = $PWD + \x-yanmangiagl-monitoring.ps1) � changer apr�s si y'a le temps
$startPath = "D:\FIN22-24\FIN2\00-TPI\tpi\scripts\x-yanmangiagl-monitoring.ps1"
$destinationPath = "C:\Scripts"

foreach($computer in $computerList){
    # Connexion � ordinateur distant
    $remotename = [System.Net.Dns]::GetHostByAddress($computer).Hostname

    # Cr�ation d'une session
    $session = New-PSSession -ComputerName $remotename -Credential $credentials

    # Copie depuis machine locale du fichier et colle sur la machine distante ou la liste d'ordinateur
    Copy-Item $startPath -Destination $destinationPath -ToSession $session

    Invoke-Command -Session $session -ScriptBlock {
       # Concatenation du chemin
       $fullpath = $destinationPath + '\x-yanmangiagl-monitoring.ps1'

       # Creation d'une t�che planifiee
       $task = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $fullpath
       $taskInterval = New-ScheduledTaskTrigger -Daily -At 4PM
       $taskName = "MonitoringAuto4PM"
       $taskDesc = "R�cup�re les donn�es d'un ordinateur, envoie des mails et supprime les fichiers trop volumineux"

       # Enregistrement de la tache
       Register-ScheduledTask -TaskName $taskName -Action $task -Trigger $taskInterval -Description $taskDesc
    }
}