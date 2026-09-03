<#
.SYNOPSIS
    Script automatizado de instalación y verificación para Free Claude Code (Pro Architecture) en Windows.
.DESCRIPTION
    Verifica Node.js, Python, Git, instala Hermes, free-claude-code, Playwright Chromium y prepara las carpetas
    con soporte para NVIDIA NIM Nemotron 120B, Google AI Studio y Groq.
#>

$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  Instalador Automatizado: Free Claude Code Pro          " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# 1. Verificar Prerrequisitos
Write-Host "`n[1/5] Verificando prerrequisitos del sistema..." -ForegroundColor Yellow

function Test-Command ($cmd) {
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

if (-not (Test-Command "node")) {
    Write-Error "Node.js no está instalado. Descárgalo de https://nodejs.org/"
} else {
    Write-Host "  ✓ Node.js detectado: $(node --version)" -ForegroundColor Green
}

if (-not (Test-Command "python")) {
    Write-Error "Python no está instalado. Descárgalo de https://python.org/"
} else {
    Write-Host "  ✓ Python detectado: $(python --version)" -ForegroundColor Green
}

if (-not (Test-Command "git")) {
    Write-Error "Git no está instalado. Descárgalo de https://git-scm.com/"
} else {
    Write-Host "  ✓ Git detectado: $(git --version)" -ForegroundColor Green
}

# 2. Instalar Hermes si no está presente
Write-Host "`n[2/5] Verificando Hermes Package Manager..." -ForegroundColor Yellow
if (-not (Test-Command "hermes")) {
    Write-Host "  Instalando Hermes..." -ForegroundColor Cyan
    iwr -useb https://raw.githubusercontent.com/hermes-agent/hermes/main/install.ps1 | iex
} else {
    Write-Host "  ✓ Hermes ya está instalado." -ForegroundColor Green
}

# Actualizar PATH de la sesión
$env:Path = [Environment]::GetEnvironmentVariable('LOCALAPPDATA') + '\hermes\bin;' + [Environment]::GetEnvironmentVariable('USERPROFILE') + '\.local\bin;' + $env:Path

# 3. Instalar free-claude-code
Write-Host "`n[3/5] Verificando free-claude-code..." -ForegroundColor Yellow
if (-not (Test-Command "fcc-server")) {
    Write-Host "  Instalando free-claude-code vía Hermes..." -ForegroundColor Cyan
    hermes install free-claude-code
} else {
    Write-Host "  ✓ free-claude-code ya está instalado." -ForegroundColor Green
}

# 4. Instalar Playwright Chromium
Write-Host "`n[4/5] Instalando navegador Chromium para Playwright MCP..." -ForegroundColor Yellow
npx -y playwright install chromium
Write-Host "  ✓ Playwright Chromium instalado." -ForegroundColor Green

# 5. Configurar archivos en $HOME
Write-Host "`n[5/5] Configurando directorios de usuario..." -ForegroundColor Yellow

$fccDir = Join-Path $HOME ".fcc"
$claudeDir = Join-Path $HOME ".claude"

if (-not (Test-Path $fccDir)) {
    New-Item -ItemType Directory -Path $fccDir -Force | Out-Null
}

$targetEnv = Join-Path $fccDir ".env"
if (-not (Test-Path $targetEnv)) {
    Copy-Item ".env.example" $targetEnv
    Write-Host "  ✓ Archivo creado: $targetEnv (Edítalo con tus API Keys de NVIDIA, Google y Groq)" -ForegroundColor Green
} else {
    Write-Host "  ✓ Archivo $targetEnv ya existía (no se sobreescribió)." -ForegroundColor Cyan
}

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

$targetClaudeMd = Join-Path $claudeDir "CLAUDE.md"
if (-not (Test-Path $targetClaudeMd)) {
    Copy-Item "CLAUDE.md.template" $targetClaudeMd
    Write-Host "  ✓ Directivas instaladas en: $targetClaudeMd" -ForegroundColor Green
} else {
    Write-Host "  ✓ Directivas $targetClaudeMd ya existían." -ForegroundColor Cyan
}

Write-Host "`n=========================================================" -ForegroundColor Green
Write-Host "  ¡Instalación Pro completada con éxito!                 " -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "Pasos siguientes:"
Write-Host "1. Abre $targetEnv y coloca tus claves (NVIDIA NIM, Google AI Studio, Groq)."
Write-Host "2. Ejecuta '.\iniciar-todo.ps1' para arrancar el proxy y Claude Code en modo autónomo."
Write-Host "3. O pasa una tarea directa: '.\iniciar-todo.ps1 -p ""tu tarea aquí""'"
