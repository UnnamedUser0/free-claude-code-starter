# ==============================================================================
# SCRIPT DE INICIO RÁPIDO: FREE CLAUDE CODE (MODO AUTÓNOMO Y ASÍNCRONO)
# ==============================================================================
# Inicia el proxy local en segundo plano (puerto 8082), verifica su salud
# y lanza Claude Code listo para trabajar sin interrupciones ni permisos manuales.

$ErrorActionPreference = "Stop"

# 1. Iniciar el servidor proxy en una nueva ventana de PowerShell
Write-Host "`n[1/3] Iniciando servidor proxy local (free-claude-code)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "fcc-server"

# 2. Esperar a que el proxy esté respondiendo en el puerto 8082 (polling hasta 15 segundos)
Write-Host "[2/3] Verificando salud del proxy en http://localhost:8082..." -ForegroundColor Yellow
$healthy = $false
$retries = 0
while (-not $healthy -and $retries -lt 15) {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8082/health" -Method Get -ErrorAction SilentlyContinue
        if ($response.status -eq "healthy") {
            $healthy = $true
        }
    } catch {
        # Esperando arranque del servidor uvicorn
    }
    if (-not $healthy) {
        Start-Sleep -Seconds 1
        $retries++
    }
}

if ($healthy) {
    # Garantizar directivas maestras en el directorio de trabajo
    if (-not (Test-Path "CLAUDE.md")) {
        $globalClaude = Join-Path $HOME ".claude\CLAUDE.md"
        if (Test-Path $globalClaude) {
            Copy-Item $globalClaude "CLAUDE.md"
            Write-Host "  ✓ Directivas maestras CLAUDE.md sincronizadas en el directorio actual." -ForegroundColor Green
        }
    }

    # 3. Lanzar Claude Code configurado con el proxy (modo autónomo manos libres)
    Write-Host "[3/3] ¡Proxy activo y saludable! Iniciando Claude Code..." -ForegroundColor Green
    
    $launchArgs = @()
    # Inyectar automáticamente el modo autónomo si no se especificó un modo de permisos
    if (-not ($args -contains "--dangerously-skip-permissions") -and -not ($args -contains "--permission-mode")) {
        $launchArgs += "--dangerously-skip-permissions"
    }
    if ($args.Count -gt 0) {
        $launchArgs += $args
    }
    
    fcc-claude $launchArgs
} else {
    Write-Warning "El proxy no respondió en el tiempo límite. Verifica los logs o ejecuta 'fcc-server' manualmente."
}
