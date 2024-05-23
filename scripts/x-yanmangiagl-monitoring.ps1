<#
.NOTES
    Nom: x-yanmangiagl-monitoring.ps1
    Auteur: Yann Mangiagli
    Date de cr�ation: 15 mai 2024


.SYNOPSIS
    R�cup�re les donn�es d'un ordinateur, envoie des mails et supprime les fichiers trop volumineux

.DESCRIPTION
    R�cup�re le nom, la version, le stockage utilis�, le stockage libre, le version des mises � jour
    Envoie un mail � une adresse mail donnant les informations de la machine ayant 80%+ de stockage utilis�
    Supprime les fichiers OVA de plus de 3 Go

.EXAMPLE
.\x-yanmangiagl-monitoring.ps1

.PARAMETER X

.LINK
    https://github.com/Yann-Mangiagli/tpi/tree/main/scripts
#>

# Tableau de valeurs
$valuesArray = @{
    MachineNom = "x";
    VersionOS = "x";
    EspaceUtilise = "x";
    EspaceLibre = "x";
    VersionMAJ = "x";
    #LettreDisk = "x"
}

# R�cup�ration du nom de l'ordinateur
$valuesArray.MachineNom = $env:COMPUTERNAME

# R�cup�ration de la version de l'OS
$valuesArray.VersionOS =  $env:OS + " "+ [environment]::OSVersion.Version.Build

# R�cup�ration de l'espace disque libre et de la lettre
$valuesArray.EspaceLibre = Get-PSDrive | Select-Object free # tester -ExcludeProperty jeudi

# R�cup�ration de l'espace disque utilis�
$valuesArray.EspaceUtilise = Get-PSDrive | Select-Object Used

# R�cup�ration des versions de mise � jour de l'OS
$valuesArray.VersionMAJ = Get-HotFix -ComputerName $valuesArray.MachineNom | Select HotFixID

# Calcul du pourcentage d'utilisation du disque
$diskPercent = 80

# Si l'espace disque est plus utilis� ou �gal � 80%, entrer
if($diskPercent -ge 80){
    
    # Cr�dentiels du serveur SMTP
    $server = "smtp.gmail.com"
    $port = 587

    # D�tails de l'email
    $sender = "pappro2mail@gmail.com"
    $recipient = "tpiymetml@gmail.com"
    $subject = "Report - Disque satur�"
    $body = "L'ordinateur " + $valuesArray.MachineNom + " est surcharg�.`n
    Version de l'OS: " + $valuesArray.VersionOS + "`n
    Versions de MAJ: " + $valuesArray.VersionMAJ+ "`n" #Mettre valeur qui a �t� cr��e dans un foreach plus haut

    # Identifiants
    $password = "fxkj gfff ebmt jprz"

    #S�curisation du mot de passe
    $securePassword = ConvertTo-SecureString -string $password -AsPlainText -Force

    $creds = New-Object System.Management.Automation.PSCredential -argumentlist $sender, $securePassword

    # Envoi du mail
    Send-MailMessage -SmtpServer $server -Port $port -UseSsl -Credential $creds -From $sender -To $recipient -Subject $subject -Body $body
}