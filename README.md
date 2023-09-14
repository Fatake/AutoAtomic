# Auto Atomic

Este script realiza de forma automática, la ejecución de TTPs de Atomic Red Team
con el framework de invoke-atomicredteam, generando logs de cada TTP en formato .json que se pueden importar en la herramienta VECTR.

## Uso

Uso: `.\AutoAtomic.ps1 [-i] [-p] [-t] [-h]`
Donde:
```
-i,-InstallFramework          Instala Atomic Red Team.
-p,-PayloadsInstall           Instala los Payloads de Atomic.
-t,-TestFile                  Establece una ruta diferente a 'ttps.txt'.
                              Con otros TTPs definidos por el usuarios.
                              Si nó se especifica, su valor por defecto es 'ttps.txt'.
-h,-Help                      Muestra esta ayuda.
```

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
