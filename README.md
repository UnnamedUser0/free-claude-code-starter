# ⚡ Free Claude Code Starter Kit (Pro Architecture)

> Guía definitiva y configuración profesional de alto rendimiento para utilizar **Claude Code** de forma 100% gratuita, integrando el clúster de modelos de frontera más potente del mundo (**NVIDIA NIM Nemotron 120B, Google Gemini 2.5 Flash Lite 1M y Groq LPU**) con soporte de visión, herramientas de sistema, **modo autónomo manos libres** y **auto-sanación en tiempo real mediante Playwright MCP**.

---

## 📖 Tabla de Contenidos
1. [¿Qué es este proyecto?](#-qué-es-este-proyecto)
2. [Arquitectura Pro Multimodelo](#-arquitectura-pro-multimodelo)
3. [Comparativa de Rendimiento frente a Anthropic Oficial](#-comparativa-de-rendimiento-frente-a-anthropic-oficial)
4. [Requisitos Previos](#-requisitos-previos)
5. [Instalación Paso a Paso](#-instalación-paso-a-paso)
6. [Configuración de Proveedores (NVIDIA NIM, Google AI Studio, Groq)](#-configuración-de-proveedores-nvidia-nim-google-ai-studio-groq)
7. [Modo Autónomo ("Hands-Free") para Trabajo Asíncrono](#-modo-autónomo-hands-free-para-trabajo-asíncrono)
8. [Configuración de Playwright MCP (Ojos en el Navegador)](#-configuración-de-playwright-mcp-ojos-en-el-navegador)
9. [Reglas Maestras de Ingeniería (`CLAUDE.md`)](#-reglas-maestras-de-ingeniería-claudemd)
10. [Solución de Problemas Frecuentes (Troubleshooting)](#-solución-de-problemas-frecuentes-troubleshooting)

---

## 💡 ¿Qué es este proyecto?

**Claude Code** es el agente CLI de desarrollo de software creado por Anthropic para delegar tareas complejas de refactorización, arquitectura, generación de proyectos y pruebas directamente desde la consola.

Este repositorio contiene la configuración **Pro Architecture**, una arquitectura avanzada de servidor proxy local (`free-claude-code`) que interconecta Claude Code con clústeres de cómputo gratuitos de escala masiva (**NVIDIA NIM, Google AI Studio y Groq**). Esta arquitectura resuelve empíricamente los cuellos de botella clásicos de los proveedores gratuitos (errores 429 de cuota por minuto, 413 por límites de contexto y bucles infinitos de auto-corrección), logrando una velocidad y calidad de código equiparables a **Claude 3.5 Sonnet sin pagar suscripciones ni consumo de tokens**.

---

## 🏗️ Arquitectura Pro Multimodelo

El sistema utiliza una topología en cascada con enrutamiento inteligente y conmutación por error (*Zero-Downtime Fallback*) calibrada:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          Terminal de Usuario                           │
│                 (fcc-claude --dangerously-skip-permissions)            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Protocolo Anthropic (/v1/messages)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   Servidor Proxy Local (fcc-server)                    │
│                          Puerto Local: 8082                            │
│           (Rate Limiting: Ventana Estricta 14 req / 60s)               │
└───────┬───────────────────────────┼───────────────────────────┬────────┘
        │                           │                           │
        ▼ (Primario)                ▼ (Subtareas & Fallback)    ▼ (Opcional)
 ┌───────────────┐           ┌───────────────┐           ┌───────────────┐
 │  NVIDIA NIM   │           │  GOOGLE AI    │           │   GROQ LPU    │
 │  Nemotron     │           │  Gemini 2.5   │           │ 300 tokens/s  │
 │  Super 120B   │           │  Flash-Lite   │           │ Inferencia de │
 │(Sonnet/Opus)  │           │ (1M Contexto) │           │ baja latencia │
 └───────┬───────┘           └───────┬───────┘           └───────────────┘
         │                           │
         └─────────────┬─────────────┘
                       │
                       ▼
        ┌─────────────────────────────────────────────────────────┐
        │                  Playwright MCP Server                  │
        │      (Navegación, verificación de consola en vivo       │
        │         interacciones DOM y capturas de pantalla)       │
        └─────────────────────────────────────────────────────────┘
```

---

## 🥊 Comparativa de Rendimiento frente a Anthropic Oficial

| Nivel Claude Code | Anthropic Oficial (De Pago) | Configuración Pro Gratuita | Ventaja Técnica |
| :--- | :--- | :--- | :--- |
| **SONNET & OPUS** | Claude 3.5 / 3.7 Sonnet | **NVIDIA NIM `nemotron-3-super-120b-a12b`** | 120.000 Millones de parámetros, respuestas en **0.8 a 1.2 segundos**, compatibilidad total con tool calling y sin cuota restrictiva de 20 RPD. |
| **HAIKU** | Claude 3.5 Haiku | **Google `gemini-2.5-flash-lite`** | Memoria masiva de **1.000.000 de tokens** (elimina el límite de 8k de Groq que arrojaba error 413 Payload Too Large) y cuota de 1.500 RPD. |
| **FALLBACK RELAY** | Sin respaldo si se cae | **Gemini 2.5 Flash Lite + Gemini 3 Flash Preview** | Si el motor primario experimenta saturación temporal, conmuta en segundo plano de forma instantánea sin interrumpir la sesión. |
| **AUTONOMÍA** | Pide permisos de forma interactiva | **Modo Autónomo Hands-Free Activo** | Trabaja en tareas largas de forma asíncrona sin bloquearse esperando permisos de terminal o escritura. |

---

## 📋 Requisitos Previos

* **Node.js**: Versión 18 o superior ([nodejs.org](https://nodejs.org/))
* **Python**: Versión 3.10 o superior ([python.org](https://python.org/))
* **Git**: Para control de versiones ([git-scm.com](https://git-scm.com/))
* **PowerShell**: 5.1 o superior (incluido en Windows 10/11)

---

## 🚀 Instalación Paso a Paso

### 1. Clonar el Repositorio
```powershell
git clone https://github.com/UnnamedUser0/free-claude-code-starter.git
cd free-claude-code-starter
```

### 2. Ejecutar el Instalador Automatizado
Ejecuta en una terminal de PowerShell:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup-windows.ps1
```

El script se encargará automáticamente de:
1. Verificar Node.js, Python y Git.
2. Instalar el gestor **Hermes** y la suite **`free-claude-code`**.
3. Descargar e instalar el binario de **Chromium para Playwright MCP**.
4. Inicializar las carpetas `$HOME\.fcc` y `$HOME\.claude`.
5. Desplegar los archivos de configuración base (`.env` y `CLAUDE.md`).

---

## 🔑 Configuración de Proveedores (NVIDIA NIM, Google AI Studio, Groq)

Abre tu archivo `$HOME\.fcc\.env` (puedes usar el archivo `.env.example` de este repositorio como plantilla) y coloca tus claves gratuitas:

```ini
# Google AI Studio (https://aistudio.google.com/)
GEMINI_API_KEY=tu_clave_aqui

# NVIDIA NIM (https://build.nvidia.com/)
NVIDIA_NIM_API_KEY=tu_clave_nvapi_aqui

# Groq Cloud (https://console.groq.com/)
GROQ_API_KEY=tu_clave_gsk_aqui
```

### Parámetros Críticos en `.env` (Calibración Probada):
* **`MODEL=nvidia_nim/nvidia/nemotron-3-super-120b-a12b`**: Motor primario de alta capacidad.
* **`MODEL_OPUS=nvidia_nim/nvidia/nemotron-3-super-120b-a12b`**
* **`MODEL_SONNET=nvidia_nim/nvidia/nemotron-3-super-120b-a12b`**
* **`MODEL_HAIKU=gemini/models/gemini-2.5-flash-lite`**: 1M de tokens para análisis y subtareas.
* **`MODEL_FALLBACKS=gemini/models/gemini-2.5-flash-lite,gemini/models/gemini-3-flash-preview`**
* **`PROVIDER_RATE_LIMIT=14`** y **`PROVIDER_RATE_WINDOW=60`**: Control estricto de tasa para evitar bloqueos por peticiones por minuto (HTTP 429).
* **`FCC_OPEN_BROWSER=false`**: Evita la apertura involuntaria del navegador al iniciar el proxy.

---

## 🤖 Modo Autónomo ("Hands-Free") para Trabajo Asíncrono

Si necesitas que Claude Code trabaje en una tarea extensa (refactorización completa, suite de pruebas, generación web) sin que se quede detenido solicitando autorización para crear archivos o ejecutar comandos:

### Opción 1: Lanzador Todo-en-Uno (Recomendado)
Usa el script incluido en este repositorio:
```powershell
.\iniciar-todo.ps1
```
Este script levanta el servidor proxy en segundo plano, valida que responda saludablemente en `http://localhost:8082/health` y lanza Claude Code inyectando automáticamente la bandera `--dangerously-skip-permissions`.

### Opción 2: Tarea Directa desde Consola
Puedes pasarle una instrucción directa para que la ejecute de principio a fin y salga al terminar:
```powershell
.\iniciar-todo.ps1 -p "Crea una suite de pruebas para el módulo de usuarios y ejecuta pytest"
```

---

## 🌐 Configuración de Playwright MCP (Ojos en el Navegador)

Claude Code incluye soporte nativo para el servidor **Playwright MCP**, permitiéndole abrir un navegador real, auditar la consola JavaScript en busca de errores, interactuar con elementos de la interfaz y tomar capturas de pantalla.

Verifica que tu archivo de configuración de Claude (`~/.claude.json` o configuración global) contenga el servidor MCP:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"]
    }
  }
}
```

Para verificar su estado en cualquier momento:
```powershell
fcc-claude mcp list
# Resultado esperado: playwright: npx -y @executeautomation/playwright-mcp-server - √ Connected
```

---

## 📜 Reglas Maestras de Ingeniería (`CLAUDE.md`)

El archivo `CLAUDE.md` desplegado en tu carpeta de usuario contiene salvaguardas que eliminan los fallos comunes de los modelos LLM:

1. **Detección Estricta de Entorno (Anti-Alucinación)**:
   - Si no existe un archivo `package.json` en el directorio de trabajo, el modelo tiene **estrictamente prohibido** intentar importar `./node_modules`. Debe utilizar scripts CDN estándar o `<script type="importmap">`.
2. **Rutas Locales Relativas**:
   - Prohíbe asumir rutas de contenedor o sandbox (`/mnt/data/` o `/workspace/`). Todas las rutas deben ser relativas al espacio de trabajo local actual.
3. **Circuit-Breaker (Máximo 2 Reintentos)**:
   - Si una corrección no funciona tras 2 intentos, el modelo se detiene inmediatamente para consultar al usuario en lugar de entrar en bucles de auto-reparación de 90 llamadas consecutivas.
4. **Prioridad Quirúrgica: `Edit` sobre `Write`**:
   - Para modificar funciones o corregir bugs, el modelo debe usar parches quirúrgicos con `Edit`. Queda prohibido reescribir archivos enteros con `Write`, ahorrando hasta un 90% de consumo de tokens y preservando las cuotas.
5. **Filtrado de Advertencias en Playwright**:
   - Ignora advertencias benignas de consola (como el aviso de producción de Tailwind CDN) y solo interrumpe ante errores fatales reales (`[error]` y `[exception]`).

---

## 🛠️ Solución de Problemas Frecuentes (Troubleshooting)

### 1. `Error 429 Too Many Requests: Quota exceeded for metric ... limit: 20 per day`
* **Causa:** El nivel gratuito de Google AI Studio para ciertos modelos (como `gemini-2.5-flash`) en cuentas estándar tiene un límite diario de 20 peticiones por día (RPD).
* **Solución:** Configurar como motor primario a **`nvidia_nim/nvidia/nemotron-3-super-120b-a12b`** en `.env`. Nemotron cuenta con alta disponibilidad, no se agota con esa cuota diaria y responde en ~1 segundo.

### 2. `Error 413 Payload Too Large en Groq`
* **Causa:** Groq impone un límite estricto de ~8.000 tokens por petición en su nivel gratuito. Si el contexto del proyecto crece, Groq rechaza la llamada.
* **Solución:** Asignar `MODEL_HAIKU=gemini/models/gemini-2.5-flash-lite`. Gemini Flash-Lite cuenta con una ventana de contexto de **1.000.000 de tokens**, eliminando el error 413 por completo.

### 3. `Error 400 Bad Request en Fallback de NVIDIA`
* **Causa:** Modelos de visión puros (como `llama-3.2-90b-vision-instruct`) rechazan los esquemas de herramientas y tool-calling de OpenAI.
* **Solución:** Usar `nvidia_nim/nvidia/nemotron-3-super-120b-a12b` en el motor principal y `gemini/models/gemini-2.5-flash-lite` en los fallbacks.

### 4. Error `claude-mem@thedotmack: false`
* **Causa:** El plugin de memoria experimental intenta conectarse a un servicio de observador no autenticado.
* **Solución:** Desactivar el plugin en `~/.claude/settings.json`:
  ```json
  {
    "model": "sonnet",
    "enabledPlugins": {
      "claude-mem@thedotmack": false
    }
  }
  ```

---

## 📄 Licencia

Distribuido bajo la Licencia MIT. Consulta el archivo `LICENSE` para más información.
