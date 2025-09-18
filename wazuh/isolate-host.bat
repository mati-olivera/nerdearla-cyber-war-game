@echo off

:: isolate-host.bat
:: Script para aislar un agente Windows bloqueando todo el tráfico saliente excepto al manager de Wazuh.

set ACTION=%1
set WAZUH_MANAGER="IP_DE_TU_SERVIDOR_WAZUH"  :: ¡IMPORTANTE! Reemplaza esto con la IP de tu servidor Wazuh.
set RULE_NAME="Wazuh-Isolation"

:: Añade la lógica para el aislamiento
if /i "%ACTION%" == "add" (
    :: Primero, creamos una regla para PERMITIR la comunicación con el manager de Wazuh.
    netsh advfirewall firewall add rule name=%RULE_NAME%-Allow-Manager dir=out action=allow remoteip=%WAZUH_MANAGER%

    :: Luego, creamos una regla con prioridad más baja para BLOQUEAR todo el resto del tráfico saliente.
    netsh advfirewall firewall add rule name=%RULE_NAME%-Block-All dir=out action=block

    goto :eof
)

:: Añade la lógica para quitar el aislamiento
if /i "%ACTION%" == "delete" (
    :: Eliminamos ambas reglas por su nombre para revertir el aislamiento.
    netsh advfirewall firewall delete rule name=%RULE_NAME%-Block-All
    netsh advfirewall firewall delete rule name=%RULE_NAME%-Allow-Manager

    goto :eof
)

echo "Uso: %0 {add|delete}"
exit /b 1