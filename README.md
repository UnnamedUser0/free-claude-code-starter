# ⚡ Free Claude Code Starter Kit (Tier-0 Architecture)

> Guía definitiva y configuración profesional de alto rendimiento para utilizar **Claude Code** de forma 100% gratuita, integrando el clúster de modelos de frontera más potente del mundo (**Groq LPU a 300 t/s, Google Gemini 2.5 Flash 1M, Meta Llama 90B y NVIDIA Nemotron 120B**) con soporte de visión, herramientas de sistema y **auto-sanación en tiempo real mediante Playwright MCP**.

---

## 📖 Tabla de Contenidos
1. [¿Qué es este proyecto?](#-qué-es-este-proyecto)
2. [Arquitectura Tier-0 Multimodelo](#-arquitectura-tier-0-multimodelo)
3. [Comparativa de Rendimiento frente a Anthropic](#-comparativa-de-rendimiento-frente-a-anthropic)
4. [Requisitos Previos](#-requisitos-previos)
5. [Instalación Paso a Paso](#-instalación-paso-a-paso)
6. [Configuración de Proveedores (Google, Groq, NVIDIA)](#-configuración-de-proveedores-google-groq-nvidia)
7. [Configuración de Playwright MCP (Ojos en el Navegador)](#-configuración-de-playwright-mcp-ojos-en-el-navegador)
8. [Reglas Maestras de Ingeniería (`CLAUDE.md`)](#-reglas-maestras-de-ingeniería-claudemd)
9. [Uso Diario y Selección de Modelos (`/model`)](#-uso-diario-y-selección-de-modelos-model)
10. [Solución de Problemas Frecuentes](#-solución-de-problemas-frecuentes)

---

## 💡 ¿Qué es este proyecto?

**Claude Code** es el revolucionario agente CLI de desarrollo de software creado por Anthropic. Permite delegar tareas complejas de refactorización, creación de proyectos y depuración directamente desde la consola.

Este repositorio contiene la configuración **Tier-0**, una arquitectura avanzada de servidor proxy local (`free-claude-code`) que interconecta Claude Code con los proveedores gratuitos de mayor escala de cómputo del planeta (**Groq, Google AI Studio y NVIDIA NIM**). Esto te permite alcanzar una velocidad y calidad de código equiparables a **Claude 3.5 / 3.7 Sonnet y Opus sin pagar suscripciones ni consumo de tokens**.

---

## 🏗️ Arquitectura Tier-0 Multimodelo

El sistema utiliza una topología en cascada con conmutación por error (*fallback relay*) automática:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          Terminal de Usuario                           │
│                              (fcc-claude)                              │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Protocolo Anthropic (/v1/messages)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   Servidor Proxy Local (fcc-server)                    │
│                          Puerto Local: 8082                            │
└───────┬───────────────────────────┼───────────────────────────┬────────┘
        │                           │                           │
        ▼                           ▼                           ▼
 ┌───────────────┐           ┌───────────────┐           ┌───────────────┐
 │   GROQ LPU    │           │  GOOGLE AI    │           │  NVIDIA NIM   │
 │ 300 tokens/s  │           │ 1M de Contexto│           │   Gpu H100    │
 │ GPT-OSS 120B  │           │ Gemini 2.5    │           │ Llama 3.2 90B │
 │  (Opus Tier)  │           │ Flash(Sonnet) │           │ Nemotron 120B │
 └───────────────┘           └───────────────┘           └───────────────┘
        ▲                           ▲                           ▲
        └───────────────────────────┼───────────────────────────┘
                                    │
                                    ▼
       ┌─────────────────────────────────────────────────────────┐
       │                  Playwright MCP Server                  │
       │    (Diagnóstico de consola y auto-sanación visual)      │
       └─────────────────────────────────────────────────────────┘
```

---

## 🥊 Comparativa de Rendimiento frente a Anthropic

| Nivel Claude Code | Anthropic Oficial (De Pago) | Tu Configuración Tier-0 | Ventaja Técnica |
| :--- | :--- | :--- | :--- |
| **OPUS** | Claude 3 Opus / 3.7 | **Groq `openai/gpt-oss-120b`** | 120.000 Millones de parámetros con razonamiento profundo en chips LPU a 300 t/s. |
| **SONNET** | Claude 3.5 Sonnet | **Google `gemini-2.5-flash`** | Memoria masiva de **1.000.000 de tokens** (5 veces más que Anthropic) y alta precisión en código. |
| **HAIKU** | Claude 3.5 Haiku | **Groq `qwen/qwen3.8-27b`** | Respuestas ultrarrápidas de terminal en **200 milisegundos**. |
| **RELEVO ANTI-429** | Sin respaldo si se satura | **Meta Llama 90B + Nemotron 120B** | Cero caídas: si una API alcanza su cuota por minuto, conmuta al instante sin interrumpir. |

---

## 📋 Requisitos Previos

* **Node.js**: Versión 18 o superior ([nodejs.org](https://nodejs.org/))
* **Python**: Versión 3.10 o superior ([python.org](https://python.org/))
* **Git**: Para control de versiones y terminal Git Bash ([git-scm.com](https://git-scm.com/))
* **Hermes Package Manager**: Gestor de entornos para herramientas CLI.

---

## 🚀 Instalación Paso a Paso

### 1. Instalar Hermes y Free Claude Code
Ejecuta en una terminal de PowerShell:

```powershell
# Instalar el gestor Hermes
iwr -useb https://raw.githubusercontent.com/hermes-agent/hermes/main/install.ps1 | iex

# Actualizar variables de entorno de la sesión
$env:Path = [Environment]::GetEnvironmentVariable('LOCALAPPDATA') + '\hermes\bin;' + [Environment]::GetEnvironmentVariable('USERPROFILE') + '\.local\bin;' + $env:Path

# Instalar el ecosistema free-claude-code
hermes install free-claude-code
```

### 2. Instalar el Servidor MCP de Playwright
Playwright permite que Claude Code inspeccione la consola del navegador y corrija errores visuales en tiempo real:

```powershell
npx -y playwright install chromium
```

---

## 🔑 Configuración de Proveedores (Google, Groq, NVIDIA)

1. Prepara tu carpeta de configuración en tu directorio de usuario:
   ```powershell
   New-Item -ItemType Directory -Path "$HOME\.fcc" -Force
   Copy-Item .env.example "$HOME\.fcc\.env"
   ```
2. Edita `$HOME\.fcc\.env` y coloca tus claves gratuitas:

### ¿Dónde obtener las API Keys Gratuitas?
1. **Google AI Studio (Gemini 2.5 Flash):** [aistudio.google.com](https://aistudio.google.com/) ➔ Obtén tu clave en 1 clic.
2. **Groq Cloud (Inferencia a 300 t/s):** [console.groq.com](https://console.groq.com/) ➔ Crea una API key gratuita `gsk_...`.
3. **NVIDIA NIM (Clúster de Respaldo H100):** [build.nvidia.com](https://build.nvidia.com/) ➔ Crea una cuenta de desarrollador y obtén tu `nvapi-...`.

---

## 🌐 Configuración de Playwright MCP (Ojos en el Navegador)

Configura el servidor Playwright en tu archivo de configuración de Claude (`~/.claude/mcp_settings.json` o `~/.claude/claude_desktop_config.json`):

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

Para que el modelo trabaje con nivel de Ingeniero Senior Principal, copia la plantilla de directivas en tu raíz de Claude:

```powershell
Copy-Item CLAUDE.md.template "$HOME\.claude\CLAUDE.md"
```

### Blindajes Incluidos:
* **Bucle de Auto-Sanación Obligatorio:** Abre el servidor local, inspecciona `playwright_console_logs` y corrige recursivamente hasta lograr 0 excepciones.
* **Estándar de Import Map para Three.js:** Previene el error `Failed to resolve module specifier "three"` obligando a usar siempre `<script type="importmap">` en proyectos WebGL.
* **Edición Quirúrgica:** Exige `Read` previo antes de `Edit` para garantizar reemplazos con 100% de precisión de indentación.
* **Prohibición de Sintaxis Privada `#`:** Asegura que los colores numéricos en Three.js usen `0x3b3b98` o `'#3b3b98'` como strings válidos.

---

## 💻 Uso Diario y Selección de Modelos (`/model`)

### 1. Iniciar el Servidor Proxy
Abre PowerShell y arranca el servidor:
```powershell
fcc-server
```

### 2. Iniciar Claude Code
En tu carpeta de trabajo:
```powershell
fcc-claude
```

### 3. Alternar entre Modelos
Escribe en la línea de comandos de Claude:
```text
/model
```
* **Opus:** Activa **Groq `openai/gpt-oss-120b`** para diseño de arquitectura, matemáticas y lógica profunda.
* **Sonnet:** Activa **Gemini 2.5 Flash** para escribir código continuo con 1M de memoria.
* **Haiku:** Activa **Groq `qwen/qwen3.8-27b`** para respuestas inmediatas de terminal.

También puedes iniciarlo directamente indicando el modelo:
```powershell
fcc-claude --model opus
fcc-claude --model sonnet
```

---

## 🔧 Solución de Problemas Frecuentes

### 1. Liberar puertos en uso (8080 u 8082)
```powershell
$conns = Get-NetTCPConnection -LocalPort 8080,8082 -ErrorAction SilentlyContinue
if ($conns) { Stop-Process -Id ($conns.OwningProcess | Select-Object -Unique) -Force }
```

### 2. Evitar errores de límite de peticiones (429)
El archivo de configuración ya incluye `MODEL_FALLBACKS`. Si Google o Groq entran en un límite de enfriamiento por minuto, el proxy pasa de forma invisible a los modelos de 90B y 120B de NVIDIA sin arrojar ningún error en tu consola.

---

## 📄 Licencia
Distribuido bajo la licencia MIT. Libre para uso personal y desarrollo profesional.
