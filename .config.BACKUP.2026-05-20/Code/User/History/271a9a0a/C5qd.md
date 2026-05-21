# Portfolio - Diorges Leal

Portafolio personal desarrollado con **Next.js 15** y **React 19**, desplegado estáticamente en **GitHub Pages**.

## 🚀 Tecnologías

- **Framework**: Next.js 15 (App Router)
- **UI**: React 19, Tailwind CSS 4
- **Temas**: next-themes (soporte dark/light mode)
- **Iconos**: lucide-react
- **Email**: EmailJS para formulario de contacto
- **Despliegue**: GitHub Pages (exportación estática)

## 📋 Prerrequisitos

- Node.js 18+
- npm

## ⚙️ Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/DenLion09/portfolio.git
   cd portfolio
   ```

2. Instala las dependencias:

   ```bash
   npm install
   ```

3. Configura las variables de entorno:

   ```bash
   cp .env.example .env.local
   ```

   Edita `.env.local` con tus credenciales de EmailJS.

4. Inicia el servidor de desarrollo:

   ```bash
   npm run dev
   ```

Abre [http://localhost:3000](http://localhost:3000) en tu navegador.

## 📦 Scripts Disponibles

| Script          | Descripción                                |
| --------------- | ------------------------------------------ |
| `npm run dev`   | Servidor de desarrollo con Turbopack       |
| `npm run build` | Build de producción (exportación estática) |
| `npm run start` | Servidor de producción local               |
| `npm run lint`  | Linter con ESLint                          |

## 🏗️ Estructura del Proyecto

```
portfolio/
├── app/              # App Router (Next.js 15)
├── components/       # Componentes React (atoms, molecules, organisms)
├── config/           # Configuración centralizada
├── lib/              # Utilidades y funciones (GitHub API, validación)
├── hooks/            # Custom hooks (React)
├── public/           # Archivos estáticos
└── .github/          # GitHub workflows y templates
```

## 🌐 Despliegue

El proyecto usa **GitHub Pages** con exportación estática:

- El workflow en `.github/workflows/deploy.yml` maneja el despliegue automático
- La configuración en `next.config.mjs` está optimizada para GitHub Pages (`/portfolio` basePath)
- Solo se usan características estáticas (sin API routes del lado del servidor)

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 🔗 Enlaces

- **Portafolio**: [https://denlion09.github.io/portfolio](https://denlion09.github.io/portfolio)
- **GitHub**: [@DenLion09](https://github.com/DenLion09)
- **LinkedIn**: [diorges](https://linkedin.com/in/diorges)

---

⚡ Construido con pasión por Diorges Leal
