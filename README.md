# Auto Atomic

Este script realiza de forma automática, la ejecución de TTPs de Atomic Red Team
con el framework de invoke-atomicredteam, generando logs de cada TTP en formato .json que se pueden importar en la herramienta VECTR.


## Uso

Uso: `.\AutoAtomic.ps1 [-i] [-p] [-h]`

-i    Instala Atomic Red Team.
-p   Instala los Payloads de Atomic.
-h   Muestra esta ayuda."

### Ejemplos

Para installar framework de Atomic Red Team con Payloads:

```powershell
.\AutoAtomic.ps1 -i -p
```

Para installar solo instalar el framework de Atomic Red Team:

```powershell
.\AutoAtomic.ps1 -i
```


Para ejecución normal de las TTP

```powershell
.\AutoAtomic.ps1
```


> Para La ejecución de este escript, se requiere de un archivo llamado ttps.txt donde se contenga en forma de lista las TTP en número.
> Cada TTP puede tener '**-Numero**' al final para indicar el numero de test a ejecutar, P/E:

**[File ttps.txt]**

```
T1033
T1087.002
T1497.001-2
```


[i] Creado por [Fatake](https://)
