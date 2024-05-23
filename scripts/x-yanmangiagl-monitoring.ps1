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
    VersionMAJ = "x";
    #LettreDisk = "x"
}

# Récupération du nom de l'ordinateur
$valuesArray.MachineNom = $env:COMPUTERNAME

# Récupération de la version de l'OS
$valuesArray.VersionOS =  $env:OS + " "+ [environment]::OSVersion.Version.Build

# Récupération de l'espace disque libre et de la lettre
$valuesArray.EspaceLibre = Get-PSDrive | Select-Object free # tester -ExcludeProperty jeudi

# Récupération de l'espace disque utilisé
$valuesArray.EspaceUtilise = Get-PSDrive | Select-Object Used

# Récupération des versions de mise à jour de l'OS
$valuesArray.VersionMAJ = Get-HotFix -ComputerName $valuesArray.MachineNom | Select HotFixID

# Calcul du pourcentage d'utilisation du disque
$diskPercent = 80

# Si l'espace disque est plus utilisé ou égal à 80%, entrer
if($diskPercent -ge 80){
    
    # Crédentiels du serveur SMTP
    $server = "smtp.gmail.com"
    $port = 587

    # Détails de l'email
    $sender = "pappro2mail@gmail.com"
    $recipient = "tpiymetml@gmail.com"
    $subject = "Report - Disque saturé"
    $body = "L'ordinateur " + $valuesArray.MachineNom + " est surchargé.`n
    Version de l'OS: " + $valuesArray.VersionOS + "`n
    Versions de MAJ: " + $valuesArray.VersionMAJ+ "`n" #Mettre valeur qui a été créée dans un foreach plus haut

    # Identifiants
    $password = "fxkj gfff ebmt jprz"

    #Sécurisation du mot de passe
    $securePassword = ConvertTo-SecureString -string $password -AsPlainText -Force

    $creds = New-Object System.Management.Automation.PSCredential -argumentlist $sender, $securePassword

    # Envoi du mail
    Send-MailMessage -SmtpServer $server -Port $port -UseSsl -Credential $creds -From $sender -To $recipient -Subject $subject -Body $body
}