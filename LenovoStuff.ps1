if ((Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer).Manufacturer -ne "LENOVO")
{
    if  (-not (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer).Model.StartsWith("2")) {
        Write-Warning "Not a Lenovo ThinkPad, exiting."
        Exit
    }
}

# Lenovo Commercial Vantage might require a NuGet upgrade
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
winget install --scope machine --disable-interactivity --accept-source-agreements --silent "Lenovo Commercial Vantage"

# get https://download.lenovo.com/pccbbs//thinkvantage_en/metroapps/Vantage/ChargeThreshold/ChargeThreshold.exe
if (-not (Test-Path -Path "$PSScriptRoot/ChargeThreshold.exe")) 
{
    Invoke-WebRequest -Uri "https://download.lenovo.com/pccbbs//thinkvantage_en/metroapps/Vantage/ChargeThreshold/ChargeThreshold.exe" -OutFile "$PSScriptRoot/ChargeThreshold.exe"
    # requires Lenovo Battery manager. Note -- I think this is only versiion 10.2.26 09 Sep 2005, but it's too hard to figure out latest
    Invoke-WebRequest -Uri  https://download.lenovo.com/pccbbs/mobiles/n1fupa5w.exe -OutFile "$PSScriptRoot/n1fupa5w.exe"
    . $PSScriptRoot/n1fupa5w.exe
}
. $PSScriptRoot/ChargeThreshold.exe on 80 75
