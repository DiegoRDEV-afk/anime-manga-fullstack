# 🎬 Anime Stream API (Feature-Driven Backend)

Sistema de API para scraping y resolución de enlaces de video de múltiples proveedores de anime, desarrollado en Node.js (v18+) bajo una arquitectura orientada a características (**Feature-Driven Architecture**).

Este proyecto sirve como el backend principal para nuestra aplicación móvil híbrida en Flutter.

---

## 🚀 Características del Proyecto

* 🗂️ **Arquitectura Limpia:** Organización por características (`features/`) que mapea 1:1 con los módulos de la app móvil.
* 🕵️‍♂️ **Multi-Proveedor:** Soporte modular para scrapers (AnimeAV1, TioAnime, AnimeFLV, JKAnime, MonosChinos, HentaiLA).
* ⚡ **Resolución Paralela:** Extractores optimizados para obtener enlaces limpios de video (Streamwish, VOE, Streamtape) evadiendo publicidad.
* ⬇️ **Motor de Descargas:** Preparado para soportar descargas en segundo plano por bloques.

---

## 🛠️ Tecnologías Utilizadas

* **Node.js** (v18) & Express
* **Axios** (Peticiones HTTP con rotación de User-Agents)
* **Cheerio** (Scraping y parsing de HTML)
* **Puppeteer** (Navegador headless para bypass de Cloudflare)

---

## 📁 Estructura del Proyecto

El proyecto está organizado de la siguiente manera:

* `src/features/anime/` - Gestión de catálogo, detalles y búsquedas de los proveedores.
* `src/features/player/` - Extractores y resolvedores de enlaces de video de los servidores.
* `src/features/download/` - Lógica y motor para la descarga de capítulos.
* `src/shared/` - Utilidades globales, middlewares de errores y configuraciones comunes.

---

## 🛠️ Instalación y Configuración Local

1. Clonar el repositorio:
<code>git clone https://github.com/TU_USUARIO/TU_REPOSITORIO.git</code>

2. Instalar las dependencias:
<code>npm install</code>

3. Crear un archivo `.env` en la raíz del proyecto y configurar el puerto:
<code>PORT=3000</code>

4. Iniciar el servidor en modo desarrollo:
<code>npm start</code>