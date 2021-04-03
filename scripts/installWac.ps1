$ProgressPreference = "SilentlyContinue"

mkdir -Path "C:\WAC"

## Download the MSI file
Invoke-WebRequest -UseBasicParsing -Uri 'https://aka.ms/WACDownload' -OutFile "C:\WAC\WindowsAdminCenter.msi"


## install Windows Admin Center
$msiArgs = @("/i", "C:\WAC\WindowsAdminCenter.msi", "/qn", "/L*v", "log.txt", "SME_PORT=443", "SSL_CERTIFICATE_OPTION=generate")
Start-Process msiexec.exe -Wait -ArgumentList $msiArgs
