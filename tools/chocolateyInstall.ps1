﻿$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + `
    ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$packageName = 'gnuradio'
$installerType = 'EXE' 
$url = 'http://files.ettus.com/binaries/gnuradio/gnuradio_v3.7.3/gnuradio_3.7.3_Win32.exe' 
$silentArgs = '/S' 
$validExitCodes = @(0) 

python -m pip install --upgrade pip
pip install lxml cheetah

$dest = "${Env:ProgramFiles(x86)}"

function Install-ChocolateyPathlike {
param(
  [string] $path,
  [string] $pathToInstall,
  [System.EnvironmentVariableTarget] $pathType = [System.EnvironmentVariableTarget]::User
)
  Write-Debug "Running 'Install-ChocolateyPath' with pathToInstall:`'$pathToInstall`'";
  $originalPathToInstall = $pathToInstall

  #get the PATH variable
  $envPath = Get-EnvironmentVariable -Name $path -Scope $pathType
  if($envPath -eq $null) {
    $envPath = ""
  }
  if (!$envPath.ToLower().Contains($pathToInstall.ToLower()))
  {
    Write-Host "$path environment variable does not have $pathToInstall in it. Adding..."
    $actualPath = Get-EnvironmentVariable -Name $path -Scope $pathType

    $statementTerminator = ";"
    #does the path end in ';'?
    $hasStatementTerminator = $actualPath -ne $null -and $actualPath.EndsWith($statementTerminator)
    # if the last digit is not ;, then we are adding it
    If (!$hasStatementTerminator -and $actualPath -ne $null) {$pathToInstall = $statementTerminator + $pathToInstall}
    if (!$pathToInstall.EndsWith($statementTerminator)) {$pathToInstall = $pathToInstall + $statementTerminator}
    $actualPath = $actualPath + $pathToInstall

    if ($pathType -eq [System.EnvironmentVariableTarget]::Machine) {
      if (Test-ProcessAdminRights) {
        Set-EnvironmentVariable -Name $path -Value $actualPath -Scope $pathType
      } else {
        $psArgs = "Install-ChocolateyPath -pathToInstall `'$originalPathToInstall`' -pathType `'$pathType`'"
        Start-ChocolateyProcessAsAdmin "$psArgs"
      }
    } else {
      Set-EnvironmentVariable -Name $path -Value $actualPath -Scope $pathType
    }
  }
}


Install-ChocolateyPath "$dest\gnuradio\bin" "Machine"

Install-ChocolateyPathlike "PYTHONPATH" "C:\Program Files (x86)\gnuradio\lib\site-packages" 

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -validExitCodes $validExitCodes





