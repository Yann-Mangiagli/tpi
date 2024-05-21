# SMTP server information
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
 
# Email details
$smtpFrom = "pappro2mail@gmail.com"
$smtpTo = "tpiymetml@gmail.com"
$subject = "Your Subject Here"
$body = "Your email body content here."
 
#Setup User name and Password
$UserName = "pappro2mail@gmail.com"
$Password = "fxkj gfff ebmt jprz" #Insert your App Password here
$SecurePassword = ConvertTo-SecureString -string $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential -argumentlist $UserName, $SecurePassword
 
# Send email from Gmail
Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $Cred -From $smtpFrom -To $smtpTo -Subject $subject -Body $Body
