@echo off
setlocal enabledelayedexpansion

echo =========================================================
echo   Iniciando Free Claude Code (CMD / Modo Autonomo)
echo =========================================================

:: 1. Detectar ejecutables en PATH o en .local\bin
set "FCC_SERVER=fcc-server"
set "FCC_CLAUDE=fcc-claude"

if exist "%USERPROFILE%\.local\bin\fcc-server.exe" (
    set "FCC_SERVER=%USERPROFILE%\.local\bin\fcc-server.exe"
)
if exist "%USERPROFILE%\.local\bin\fcc-claude.exe" (
    set "FCC_CLAUDE=%USERPROFILE%\.local\bin\fcc-claude.exe"
)

:: 2. Iniciar el servidor proxy en una ventana separada
echo [1/3] Iniciando servidor proxy local en segundo plano...
start "Proxy free-claude-code" cmd /c ""!FCC_SERVER!""

:: 3. Esperar a que el proxy este respondiendo en el puerto 8082
echo [2/3] Esperando a que el proxy responda en http://localhost:8082/health...
set /a retries=0

:check_health
curl.exe -s http://localhost:8082/health | findstr /i "healthy" >nul 2>&1
if %errorlevel% equ 0 (
    echo [2/3] Proxy activo y saludable en puerto 8082.
    goto launch_claude
)

set /a retries+=1
if %retries% geq 15 (
    echo [!] Advertencia: El proxy tardo en responder. Intentando abrir Claude Code...
    goto launch_claude
)

ping -n 2 127.0.0.1 >nul
goto check_health

:launch_claude
:: Garantizar directivas de ingenieria CLAUDE.md en el directorio de trabajo
if not exist "CLAUDE.md" (
    if exist "%USERPROFILE%\.claude\CLAUDE.md" (
        copy "%USERPROFILE%\.claude\CLAUDE.md" "CLAUDE.md" >nul 2>&1
        echo [OK] Directivas maestras CLAUDE.md sincronizadas en el directorio actual.
    )
)

echo [3/3] Iniciando Claude Code en modo autonomo...
echo =========================================================

:: 4. Verificar si el usuario solicito Modo Estandar (que pida confirmacion)
echo %* | findstr /i "\-\-safe \-\-ask \-\-standard" >nul 2>&1
if %errorlevel% equ 0 (
    set "CLEAN_ARGS=%*"
    set "CLEAN_ARGS=!CLEAN_ARGS:--safe=!"
    set "CLEAN_ARGS=!CLEAN_ARGS:--ask=!"
    set "CLEAN_ARGS=!CLEAN_ARGS:--standard=!"
    echo [Modo Estandar Activo: Claude Code solicitara confirmacion interactiva]
    "%FCC_CLAUDE%" !CLEAN_ARGS!
    exit /b %errorlevel%
)

:: 5. Modo por defecto: Modo Autonomo (manos libres)
echo [Modo Autonomo Activo: Ejecucion asincrona sin solicitudes de confirmacion]
echo %* | findstr /i "dangerously-skip-permissions permission-mode" >nul 2>&1
if %errorlevel% equ 0 (
    "%FCC_CLAUDE%" %*
) else (
    if "%~1"=="" (
        "%FCC_CLAUDE%" --dangerously-skip-permissions
    ) else (
        "%FCC_CLAUDE%" --dangerously-skip-permissions %*
    )
)

exit /b %errorlevel%
