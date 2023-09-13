param (
    [switch]$Install,
    [switch]$Payload,
    [switch]$Help
)

function Show-Help {
    Write-Host ""
    Write-Host "[i] Este script realiza de forma automática, la ejecución de TTPs de Atomic Red Team"
    Write-Host "    con el framework de invoke-atomicredteam, generando logs de cada TTP"
    Write-Host "    en formato .json que se pueden importar en la herramienta VECTR."
    Write-Host ""
    Write-Host "[i] Para ejecutar este script es necesario tener permisos de ejecución de scripts"
    Write-Host "[+] Puede usar el siguiente comando $ powershell -ExecutionPolicy Bypass  "
    # set-executionpolicy remotesigned para habilitar script tambien funciona
    Write-Host ""
    Write-Host ""
    Write-Host "<---------------------- Uso --------------------->"
    Write-Host "Uso: AutoAtomic.ps1 [-i] [-p] [-h]"
    Write-Host "  -i   Instala Atomic Red Team."
    Write-Host "  -p   Instala los Payloads de Atomic."
    Write-Host "  -h   Muestra esta ayuda."
    Write-Host ""
    Write-Host ""
    Write-Host "<---------------------- Ejemplos --------------------->"
    Write-Host "Para installar framework de Atomic Red Team con Payloads:"
    Write-Host "$.\AutoAtomic.ps1 -i -p"
    Write-Host ""
    Write-Host "Para installar solo instalar el framework de Atomic Red Team:"
    Write-Host "$.\AutoAtomic.ps1 -i"
    Write-Host ""
    Write-Host "Para ejecución normal de las TTP"
    Write-Host "$.\AutoAtomic.ps1"
    Write-Host ""
    Write-Host "[!] Para La ejecución de este escript, se requiere de un archivo llamado ttps.txt"
    Write-Host "    donde se contenga en forma de lista las TTP en número."
    Write-Host "    Cada TTP puede tener '-Numero' al final para indicar el numero de test a ejecutar, P/E:"
    Write-Host ""
    Write-Host "[File ttps.txt]"
    Write-Host "T1033"
    Write-Host "T1087.002"
    Write-Host "T1497.001-2"
    Write-Host ""
    Write-Host ""
    Write-Host "[i] Creado por Fatake"
}

function Install-AtomicRedTeam {
    Write-Host "[+] Instalando Atomic Red Team"
    Install-Module -Name invoke-atomicredteam,powershell-yaml -Scope CurrentUser -Force
}

function Install-Payload {
    Write-Host "[+] Instalado Atomics Payloads"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; 
    IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing); 
    Install-AtomicRedTeam -getAtomics -Force
}

if ($Help) {
    Show-Help
    exit
}

if ($Install) {
    Install-AtomicRedTeam
}

if ($Payload) {
    Install-Payload
}

if ($Install -or $Payload) {
    Write-Host "[i] Finalizado"
    exit
}

Write-Host "<---------------------- Auto Atomic --------------------->"
Write-Host "[+] Iniciando Atomic Red team"
# Obtener la ruta absoluta del directorio que contiene el script
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path

$logFolder = Join-Path $dir "AtomicLog-$(Get-Date -UFormat %Y-%m-%d)"
if (-not (Test-Path -Path $logFolder -PathType Container)) {
    New-Item -Path $logFolder -ItemType Directory
}
Write-Host "[+] Log into: '$logFolder'."

$archivo = Join-Path $dir "ttps.txt"

# Verificar si el archivo existe
if (-not (Test-Path $archivo)) {
    Write-Error "[!] El archivo 'ttps.txt' debe estar en la misma ruta que el script"
    return
}

$totalTTPS = (Get-Content $archivo).Count
$stream = [System.IO.StreamReader] $archivo
$count = 1

while (($ttp = $stream.ReadLine()) -ne $null) {
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "<---------------------- $ttp --------------------->"
    Write-Host "[i] Test $count de $totalTTPS"
    Write-Host "[$ttp] Información"
    Invoke-AtomicTest $ttp -ShowDetails
    
    $respuesta = ""
    while ($respuesta -notin @("y", "n", "s", "e")) {
        $respuesta = Read-Host "[i] ejecutar? (y[yes]/n[no]/e[exit])"
        $respuesta = $respuesta.ToLower()
    }

    if ($respuesta -eq "e") {
        break
    } elseif ($respuesta -eq "n") {
        Write-Host "[$ttp] Test omitido."
        $count++
        continue
    }

    ### -------------------------------- Pre requisitos -------------------------
    Write-Host ""
    Write-Host "[$ttp] Pre requisitos"
    $atomlogpath = Join-Path $logFolder "${ttp}_GetPrereqs_log.json"
    $init = Get-Date

    Invoke-AtomicTest $ttp -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $atomlogpath -GetPrereqs -Confirm:$false
    
    $end = Get-Date
    Write-Host "[$ttp] Logs: $atomlogpath"
    Write-Host "[$ttp] Inicio: $init"
    Write-Host "[$ttp] Fin: $end"
    Write-Host "-----------------------"

	### -------------------------------- Execution -------------------------
    Write-Host ""
    Write-Host "[$ttp] Ejecución"
    $atomlogpath = Join-Path $logFolder "${ttp}_Execute_log.json"
    $init = Get-Date

    Invoke-AtomicTest $ttp -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $atomlogpath -Confirm:$false
    
    $end = Get-Date
    Write-Host "[$ttp] Logs: $atomlogpath"
    Write-Host "[$ttp] Inicio: $init"
    Write-Host "[$ttp] Fin: $end"
    Write-Host "-----------------------"

    ### -------------------------------- Clean -------------------------
    Write-Host ""
    Write-Host "[$ttp] Limpieza"
    $atomlogpath = Join-Path $logFolder "${ttp}_Clean_log.json"
    $init = Get-Date

    Invoke-AtomicTest $ttp -Cleanup -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $atomlogpath -Confirm:$false
    
    $end = Get-Date
    Write-Host "[$ttp] Logs: $atomlogpath"
    Write-Host "[$ttp] Inicio: $init"
    Write-Host "[$ttp] Fin: $end"
    Write-Host "<---------------------- $ttp --------------------->"
    $count++
}

# Cerrar el archivo
$stream.Close()
