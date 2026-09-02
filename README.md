# ⚡ Free Claude Code Starter Kit

> Guía definitiva y configuración profesional para utilizar **Claude Code** de forma 100% gratuita, integrando modelos de lenguaje de frontera (Google Gemini, Meta Llama, NVIDIA Nemotron y Groq) con soporte de visión, herramientas de sistema y **auto-sanación en tiempo real mediante Playwright MCP**.

---

## 📖 Tabla de Contenidos
1. [¿Qué es este proyecto?](#-qué-es-este-proyecto)
2. [Arquitectura del Sistema](#-arquitectura-del-sistema)
3. [Requisitos Previos](#-requisitos-previos)
4. [Instalación Paso a Paso](#-instalación-paso-a-paso)
5. [Configuración de Proveedores y API Keys](#-configuración-de-proveedores-y-api-keys)
6. [Configuración de Playwright MCP (Ojos en el Navegador)](#-configuración-de-playwright-mcp-ojos-en-el-navegador)
7. [Reglas Maestras de Ingeniería (`CLAUDE.md`)](#-reglas-maestras-de-ingeniería-claudemd)
8. [Uso Diario y Selección de Modelos](#-uso-diario-y-selección-de-modelos)
9. [Solución de Problemas Frecuentes](#-solución-de-problemas-frecuentes)

---

## 💡 ¿Qué es este proyecto?

**Claude Code** es el agente de línea de comandos de Anthropic diseñado para programar, navegar repositorios, ejecutar pruebas y resolver problemas de forma autónoma. Originalmente, su uso requiere una suscripción de pago o consumo de tokens en la API de Anthropic.

Este kit te enseña a levantar un **servidor proxy local (`free-claude-code`)** que traduce las peticiones del protocolo de Anthropic Messages a APIs públicas y gratuitas de Inteligencia Artificial (Google AI Studio, NVIDIA NIM, Groq), permitiéndote disfrutar de la experiencia de Claude Code con costo cero.

---

## 🏗️ Arquitectura del Sistema

```text
┌────────────────────────────────────────────────────────┐
│                   Terminal de Usuario                  │
│                     (fcc-claude)                       │
└──────────────────────────┬─────────────────────────────┘
                           │ Protocolo Anthropic (/v1/messages)
                           ▼
┌────────────────────────────────────────────────────────┐
│             Servidor Proxy Local (fcc-server)          │
│                    Puerto Local: 8082                  │
└──────────────┬───────────────────────────┬─────────────┘
               │                           │
               ▼                           ▼
 ┌───────────────────────────┐ ┌───────────────────────────┐
 │   Google Gemini 2.5 Flash │ │   NVIDIA NIM (H100)       │
 │   1M Tokens / CoT         │ │   Llama 90B / Nemotron 120B│
 └───────────────────────────┘ └───────────────────────────┘
               │                           │
               ▼                           ▼
 ┌─────────────────────────────────────────────────────────┐
 │                 Playwright MCP Server                   │
 │   (Navegador Chromium headless para auto-corrección)    │
 └─────────────────────────────────────────────────────────┘
```

---

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado en tu sistema:
* **Node.js**: Versión 18 o superior ([nodejs.org](https://nodejs.org/))
* **Python**: Versión 3.10 o superior ([python.org](https://python.org/))
* **Git**: Para gestión de repositorios y terminal Bash ([git-scm.com](https://git-scm.com/))
* **Hermes Package Manager**: Utilizado para la instalación aislada del proxy.

---

## 🚀 Instalación Paso a Paso

### 1. Instalar Hermes y Free Claude Code
Abre una terminal de PowerShell como administrador o usuario estándar y ejecuta:

```powershell
# Instalar el gestor de herramientas Hermes
iwr -useb https://raw.githubusercontent.com/hermes-agent/hermes/main/install.ps1 | iex

# Agregar las rutas al PATH de tu sesión
$env:Path = [Environment]::GetEnvironmentVariable('LOCALAPPDATA') + '\hermes\bin;' + [Environment]::GetEnvironmentVariable('USERPROFILE') + '\.local\bin;' + $env:Path

# Instalar el servidor y cliente de free-claude-code
hermes install free-claude-code
```

### 2. Instalar el Servidor MCP de Playwright
Para que Claude Code pueda abrir navegadores, leer logs de consola y corregir errores de JavaScript automáticamente:

```powershell
# Instalar Playwright globalmente
npx -y playwright install chromium
```

---

## 🔑 Configuración de Proveedores y API Keys

1. Crea la carpeta de configuración en tu directorio de usuario:
   ```powershell
   New-Item -ItemType Directory -Path "$HOME\.fcc" -Force
   ```
2. Copia el archivo `.env.example` incluido en este repositorio como `.env`:
   ```powershell
   Copy-Item .env.example "$HOME\.fcc\.env"
   ```
3. Edita `$HOME\.fcc\.env` con tu editor preferido y añade tus claves gratuitas:

### ¿Dónde conseguir las API Keys Gratuitas?
* **Google Gemini API Key:** Entra en [Google AI Studio](https://aistudio.google.com/) y genera una clave gratuita con un clic.
* **NVIDIA NIM API Key:** Entra en [build.nvidia.com](https://build.nvidia.com/), crea una cuenta de desarrollador gratuita y obtén tu `nvapi-...`.
* **Groq API Key (Opcional):** Entra en [console.groq.com](https://console.groq.com/) para inferencia ultra-rápida en chips LPU.

---

## 🌐 Configuración de Playwright MCP (Ojos en el Navegador)

Para vincular el servidor Playwright con Claude Code, crea o edita el archivo:
`~/.claude/claude_desktop_config.json` o la configuración global de MCP en `~/.claude/mcp_settings.json`:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "cmd.exe",
      "args": [
        "/c",
        "npx",
        "-y",
        "@executeautomation/playwright-mcp-server"
      ]
    }
  }
}
```

---

## 🛡️ Reglas Maestras de Ingeniería (`CLAUDE.md`)

Uno de los secretos para que un modelo libre actúe como un Ingeniero Senior de Anthropic es proporcionarle directivas estrictas en `~/.claude/CLAUDE.md`.

Copia el archivo `CLAUDE.md.template` de este repositorio en la raíz de tu carpeta de usuario de Claude:
```powershell
Copy-Item CLAUDE.md.template "$HOME\.claude\CLAUDE.md"
```

### Principales Directivas Incluidas:
1. **Bucle de Auto-Sanación Playwright:** El modelo está obligado a abrir el navegador en local, leer la consola, y si hay errores, editarlos y volver a verificar hasta tener 0 errores de consola.
2. **Estándar de Import Map para Three.js:** Evita el clásico error `TypeError: Failed to resolve module specifier "three"` obligando al modelo a incluir siempre `<script type="importmap">` en proyectos web.
3. **Edición Quirúrgica:** Exige hacer `Read` antes de `Edit` para no fallar en el reemplazo de cadenas de texto.
4. **Cero Sintaxis Privada `#` en JavaScript:** Asegura que los colores Three.js usen siempre formato numérico hexadecimal (`0x3b3b98`) en vez de strings CSS sin comillas.

---

## 💻 Uso Diario y Selección de Modelos

### 1. Iniciar el Servidor Proxy
Antes de programar, arranca el servidor local en una ventana de PowerShell:
```powershell
fcc-server
```
*(El servidor quedará escuchando en `http://127.0.0.1:8082` con el panel administrativo en `/admin`)*.

### 2. Abrir Claude Code
En tu carpeta de trabajo, abre Claude Code:
```powershell
fcc-claude
```

### 3. Cambiar de Modelo en Caliente
Dentro de la terminal de Claude Code, puedes cambiar la inteligencia del modelo escribiendo:
```text
/model
```
* **Opus:** Selecciona tu modelo de arquitectura profunda y razonamiento.
* **Sonnet:** Selecciona tu modelo para escribir código ágilmente (Gemini 2.5 Flash).
* **Haiku:** Selecciona tu modelo para respuestas instantáneas de terminal.

O directamente desde el comando de apertura:
```powershell
fcc-claude --model sonnet
fcc-claude --model opus
```

---

## 🔧 Solución de Problemas Frecuentes

### 1. Error de puerto ocupado (8080 u 8082)
Si cerraste la terminal de golpe y el puerto sigue en uso:
```powershell
$conns = Get-NetTCPConnection -LocalPort 8080,8082 -ErrorAction SilentlyContinue
if ($conns) { Stop-Process -Id ($conns.OwningProcess | Select-Object -Unique) -Force }
```

### 2. Error `429: Too Many Requests`
Google AI Studio limita las llamadas por minuto en cuentas libres. Para evitar bloqueos, el archivo `.env` ya incluye `MODEL_FALLBACKS` hacia **NVIDIA NIM (Llama 90B / Nemotron 120B)** para conmutar de inmediato y sin interrupciones.

---

## 📄 Licencia
Distribuido bajo la licencia MIT. Libre para uso personal y profesional.
