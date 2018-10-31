#enable remote management of a Windows Server
Enable-PSRemoting -Force

# Add name and IP server with GUI
$file = "$env:windir\System32\drivers\etc\hosts"
"192.168.88.1 VM2_FOR_TEST_GUI" | Add-Content -PassThru $file

# Rename server
(Get-WmiObject Win32_ComputerSystem).Rename("VM2_FOR_TEST_CORE") 

# Find interfaces
$adr = Get-NetIPInterface
$interfaces = @()
foreach ($a in $adr)
{
if ($a.AddressFamily -like "IPv4")# -and -not $a.InterfaceAlias.Contains("Loopback"))
{
$interfaces += $a.ifIndex
}
}

# Set new IP Address
New-NetIPAddress –InterfaceIndex $interfaces[0] -AddressFamily IPv4 –IPAddress 209.190.121.252 -PrefixLength 29
New-NetIPAddress –InterfaceIndex $interfaces[1] -AddressFamily IPv4 –IPAddress 192.168.88.2 -PrefixLength 24

# Set new password local Administrator
$password = ConvertTo-SecureString "dsf@Fbhc!!hc23P4P" -AsPlainText -Force
Set-LocalUser Administrator -Password $password

shutdown /r
