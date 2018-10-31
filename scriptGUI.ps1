# Add name and IP server with GUI
$file = "$env:windir\System32\drivers\etc\hosts"
"192.168.88.2 VM2_FOR_TEST_CORE" | Add-Content -PassThru $file

$available = $true
while ($available)
{
Test-WSMan -ComputerName VM2_FOR_TEST_CORE
if (-not $?)
     {
        Write-Output "Unavailable"
     }
else {$available = $false}
}

#connect to remote server (Лучше конечно поставить SSH и авторизоваться по ключу, но ввиду не хватки времени написал так)
$computerName = 'VM2_FOR_TEST_CORE'
$credential = Get-Credential
Enter-PSSession -ComputerName $computerName -Credential $credential


#install IIS with depends
Install-WindowsFeature -Name Web-Server -IncludeManagementTools -IncludeAllSubFeature

#install .NET
mkdir "C:\Program Files\dotnet"
$dotNetSdkFolder = "C:\Program Files\dotnet"
$url = "https://download.visualstudio.microsoft.com/download/pr/7010cdb4-ae43-408b-8c9f-5f94101a1c70/3e1ae56a072c7c397f10278d7643b3e9/dotnet-sdk-2.1.403-win-gs-x64.exe"
$output = "$dotNetSdkFolder\dotnet-sdk-2.1.403-win-gs-x64.exe"
bitsadmin /transfer mydownload /dynamic /download /priority FOREGROUND $url $output 
start-process -FilePath "$dotNetSdkFolder\dotnet-sdk-2.1.403-win-gs-x64.exe" -ArgumentList "/silent /accepteula" -Wait


# copy application with GitHub
$AppFolder = "C:\inetpub"
$urlApp = "https://github.com/gigazet/aspnethelloworld/archive/master.zip"
$outputApp = "$AppFolder\master.zip"
bitsadmin /transfer mydownload /dynamic /download /priority FOREGROUND $urlApp $outputApp 
$shell = new-object -com shell.application
$zip = $shell.NameSpace($outputApp)
foreach($item in $zip.items())
{
 $shell.Namespace($AppFolder).copyhere($item)
}

# Reboot server
shutdown /r

sleep 60

# Test available server
$available = $true
while ($available)
{
Test-WSMan -ComputerName VM2_FOR_TEST_CORE
if (-not $?)
     {
        Write-Output "Unavailable"
     }
else {$available = $false}
}


#connect to remote server (Лучше конечно поставить SSH и авторизоваться по ключу, но ввиду не хватки времени написал так)
$computerName = 'VM2_FOR_TEST_CORE'
$credential = Get-Credential
Enter-PSSession -ComputerName $computerName -Credential $credential


# Build and Publish Application
$AppFolder = "C:\inetpub"
cd $AppFolder\aspnethelloworld-master
dotnet build
dotnet publish


# Add rule firewall
netsh advfirewall firewall add rule name="DevOps" dir=in action=allow protocol=TCP localport=9000

# Run Application
cd $AppFolder\aspnethelloworld-master 
((Get-Content -path $AppFolder\aspnethelloworld-master\Properties\launchSettings.json -Raw) -replace '"https://localhost:5001;http://localhost:5000"','"https://192.168.88.2:9000;http://localhost:9000"') | Set-Content -Path $AppFolder\aspnethelloworld-master\Properties\launchSettings.json

dotnet run 



