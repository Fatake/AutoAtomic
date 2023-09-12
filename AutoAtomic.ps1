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

Write-Host "[+] Iniciando Atomic Red team"
# Obtener la ruta absoluta del directorio que contiene el script
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path

$logFolder = Join-Path $dir "AtomicLog-$(Get-Date -UFormat %Y-%m-%d)"
if (-not (Test-Path -Path $logFolder -PathType Container)) {
    New-Item -Path $logFolder -ItemType Directory
}
Write-Host "[+] Log into: '$logFolder'."
Write-Host "<------------------------------------------------->"

$archivo = Join-Path $dir "ttps.txt"

# Verificar si el archivo existe
if (-not (Test-Path $archivo)) {
    Write-Error "[!] El archivo 'ttps.txt' debe estar en la misma ruta que el script"
    return
}

# Abrir el archivo en modo lectura
$stream = [System.IO.StreamReader] $archivo

# Leer línea por línea y mostrar en pantalla
while (($ttp = $stream.ReadLine()) -ne $null) {
    Write-Host "<---------------------- $ttp --------------------->"
    $init = Get-Date
    echo ""
    echo ""
    echo "[$ttp] Information"
    Invoke-AtomicTest $ttp -ShowDetails
    # -TestNumbers 1,2
    echo ""
    echo ""
    echo "[$ttp] Executing"
    # Path to log
    $atomlogpath = Join-Path $logFolder "${ttp}_log.json"
    ## Execute 
    Invoke-AtomicTest $ttp -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $atomlogpath

    echo ""
    echo ""
    echo "[$ttp] Cleaning"
    Start-Sleep 3
    $atomlogpath = Join-Path $logFolder "${ttp}_Clean_log.json"
    Invoke-AtomicTest $ttp -Cleanup -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $atomlogpath

    $end = Get-Date
    echo "----------"
    Write-Host "[$ttp] Inicio: $init"
    Write-Host "[$ttp] Fin: $end"
    $respuesta = Read-Host "[i] ¿Siguiente? Escriba 'exit' para salir"

    # Si el usuario escribe "exit", salir del bucle
    if ($respuesta.ToLower() -eq "exit") {
        break
    }
}

# Cerrar el archivo
$stream.Close()
#Stop-Transcript