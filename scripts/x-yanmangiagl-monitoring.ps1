<#
.NOTES
    Nom: x-yanmangiagl-monitoring.ps1
    Auteur: Yann Mangiagli
    Date de création: 15 mai 2024


.SYNOPSIS
    Récupère les données d'un ordinateur, envoie des mails et supprime les fichiers trop volumineux

.DESCRIPTION
    Récupère le nom, la version, le stockage utilisé, le stockage libre, le version des mises à jour
    Envoie un mail à une adresse mail donnant les informations de la machine ayant 80%+ de stockage utilisé
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
    VersionMAJ = "x"
}

# Récupération du nom de l'ordinateur
$valuesArray.MachineNom = $env:COMPUTERNAME

# Récupération de la version de l'OS
$valuesArray.VersionOS =  $env:OS + " "+ [environment]::OSVersion.Version.Build

# Récupération de l'espace disque libre

# Récupération de l'espace disque utilisé

# Récupération des versions de mise à jour de l'OS

# Calcul du pourcentage d'utilisation du disque

# Si l'espace disque est plus utilisé ou égal à 80%, entrer

    # Crédentiels du serveur SMTP
    $server = "smtp.gmail.com"
    $port = 587

    # Détails de l'email
    $sender = "pappro2mail@gmail.com"
    $recipient = "tpiymetml@gmail.com"
    $subject = "Report - Disque saturé"
    $body = ""

    # Identifiants
    $password = "fxkj gfff ebmt jprz"

    #Sécurisation du mot de passe
    $securePassword = ConvertTo-SecureString -string $password -AsPlainText -Force

    $creds = New-Object System.Management.Automation.PSCredential -argumentlist $sender, $securePassword

    # Envoi du mail
    Send-MailMessage -SmtpServer $server -Port $port -UseSsl -Credential $creds -From $sender -To $recipient -Subject $subject -Body $body