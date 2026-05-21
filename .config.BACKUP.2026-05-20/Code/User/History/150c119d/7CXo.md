# Portfolio Web - Specification Document

## 1. Project Overview

**Project Name:** Portfolio Personal  
**Type:** Single Page Application (SPA) - Portfolio Website  
**Core Functionality:** Personal portfolio showcasing developer profile, projects fetched from GitHub, and contact information with theme switching capability.  
**Target Users:** Recruiters, potential clients, and fellow developers viewing the portfolio owner's work.

---

## 2. Technical Stack

### Core Technologies

- **Build Tool:** Vite 8.x
- **Styling:** Tailwind CSS 4.x + FlyonUI 2.x (CDN)
- **JavaScript:** Vanilla ES6+ (no framework)
- **Icons:** Tabler Icons (CDN)
- **Fonts:** Inter (Google Fonts)

### Dependencies

```json
{
  "devDependencies": {
    "@tailwindcss/vite": "^4.2.2",
    "tailwindcss": "^4.2.2",
    "vite": "^8.0.4"
  },
  "dependencies": {
    "dotenv": "^17.4.2",
    "flyonui": "^2.4.1"
  }
}
```

---

## 3. Architecture

### Directory Structure

```
portfolio/
├── index.html                 # Entry HTML
├── package.json               # Project config
├── vite.config.js            # Vite configuration
├── SPEC.md                   # This specification
├── public/
│   └── favicon.svg           # Favicon
└── src/
    ├── main.js               # App entry point
    ├── style.css             # Global styles + themes
    ├── components/
    │   ├── navbar.js         # Navigation bar
    │   ├── main-section.js   # Hero + Projects combined
    │   ├── hero.js           # Hero section (legacy)
    │   ├── projects.js       # Projects section (legacy)
    │   ├── contact.js        # Contact form
    │   └── footer.js         # Footer
    ├── data/
    │   ├── profile.js        # Profile data management
    │   └── projects.json     # Fallback projects
    └── lib/
        ├── github.js         # GitHub API integration
        ├── linkedin.js       # LinkedIn data integration
        ├── auth.js           # Authentication utilities
        └── security.js       # Security utilities
```

### Component Flow

```
index.html
    └── main.js
            ├── renderNavbar()
            ├── renderMainSection(profile)
            │       ├── Hero (40% width)
            │       │       ├── Avatar
            │       │       ├── Name & Title
            │       │       ├── Location
            │       │       ├── Bio
            │       │       ├── Social Links (LinkedIn, GitHub, Email)
            │       │       └── CV Download
            │       └── Projects (60% width)
            │               ├── Title
            │               ├── Scroll Container
            │               │       └── Project Cards (horizontal scroll)
            │               └── Navigation Buttons (left/right)
            └── renderFooter(profile)
```

---

## 4. UI/UX Specification

### 4.1 Layout Structure

**Page Sections:**

1. **Navbar** - Sticky top, backdrop blur, theme toggle, login button
2. **Main Section** - Split layout (Hero 40% | Projects 60%)
3. **Footer** - Newsletter, links, copyright

**Responsive Breakpoints:**

- Mobile: < 768px (stacked layout)
- Tablet: 768px - 1023px
- Desktop: >= 1024px (side-by-side layout)

**Height Configuration:**

- Main section: `min-h-[60vh]` (60% viewport height)
- Desktop hero/projects: `min-height: 60vh`

### 4.2 Color Palette

**Dark Theme (Default):**

```css
--color-bg: #0d1117; /* GitHub dark background */
--color-bg-secondary: #161b22; /* Card backgrounds */
--color-bg-tertiary: #21262d; /* Hover states */
--color-border: #30363d; /* Borders */
--color-text: #c9d1d9; /* Primary text */
--color-text-muted: #8b949e; /* Secondary text */
--color-primary: #58a6ff; /* Links, buttons */
--color-secondary: #8b949e; /* Icons */
--color-accent: #56d364; /* Success states */
--color-warning: #d29922; /* Warnings */
--color-error: #f85149; /* Errors */
```

**Light Theme:**

```css
--color-bg: #c9d1d9;
--color-bg-secondary: #ffffff;
--color-bg-tertiary: #f6f8fa;
--color-border: #d0d7de;
--color-text: #1f2328;
--color-text-muted: #656d76;
--color-primary: #0969da;
--color-secondary: #656d76;
--color-accent: #1a7f37;
--color-warning: #9a6700;
--color-error: #cf222e;
```

### 4.3 Typography

**Font Family:** Inter (Google Fonts)  
**Headings:**

- H1: 2xl - 3xl (mobile - desktop), font-bold
- H2: 2xl - 3xl, font-bold
- H3: 1.125rem, font-semibold

**Body:**

- Base: 1rem (16px)
- Small: 0.875rem (14px)
- Extra Small: 0.75rem (12px)

### 4.4 Components

**Navbar:**

- Height: sticky, backdrop-blur-md
- Background: var(--color-bg-secondary)
- Border-bottom: 1px solid var(--color-border)
- Contents: Logo (text), theme toggle (sun/moon icons), login button

**Hero Card:**

- Background: var(--color-bg-secondary)
- Shadow: shadow-2xl
- Avatar: rounded-full, ring-4 ring-primary/30
- Sizes: w-24 h-24 (mobile), w-32 h-32 (desktop)

**Project Cards:**

- Layout: Horizontal scroll with snap
- Image: 30% height, object-fit cover
- Body: Padding 1rem
- Tech badges: Small tags with background var(--color-border)
- Actions: Ver App (primary), Código (outline)
- Hover: translateY(-4px), increased shadow

**Footer:**

- Background: var(--color-bg-secondary)
- Sections: Newsletter form, GitHub links, Contact, Legal
- Copyright: Year + name

### 4.5 Animations

**Fade In Up:**

```css
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

**Delays:** 100ms, 200ms, 300ms, 400ms, 500ms

**Transitions:** 0.3s ease for hover states

---

## 5. Functionality Specification

### 5.1 Core Features

**1. Profile Management**

- Data source priority: LinkedIn > Manual (localStorage) > Hardcoded
- Profile fields: name, title, bio, location, avatar, email, github, linkedin, cvFile
- localStorage keys: `portfolio-admin`, `linkedinProfileData`

**2. GitHub Integration**

- API: `https://api.github.com/users/{username}/repos`
- Fetch 30 most recently updated repos
- Exclude repositories: ['DenLion09']
- Rate limiting: 1 second between requests
- Fallback: projects.json when API unavailable

**3. Theme Switching**

- Toggle: Click on navbar button
- Storage: localStorage key `portfolio-theme`
- Values: `dark` (default), `light`
- Application: data-theme attribute on html element

**4. Project Display**

- Horizontal scroll container
- Navigation buttons (left/right)
- GitHub stars fetched via API
- README preview (first 300 chars)
- Links: Demo (if available), Código (GitHub)

**5. Security Features**

- Input sanitization: XSS prevention via escaping
- Project sanitization: All user-provided data sanitized
- Encryption: AES-256-GCM for sensitive data
- Rate limiting: In-memory tracking

### 5.2 Data Structures

**Profile Object:**

```javascript
{
  name: string,
  title: string,
  bio: string,
  location: string,
  avatar: string,
  email: string,
  github: string,
  linkedin: string,
  cvFile: string,
  projects: Project[],
  lastUpdated: ISO8601 string,
  dataSource: 'hardcoded' | 'linkedin' | 'manual'
}
```

**Project Object:**

```javascript
{
  id: string,
  title: string,
  description: string,
  tech: string[],
  github: string,
  demo: string,
  image: string,
  tags: string[],
  readme: string (optional)
}
```

### 5.3 API Integration

**GitHub API Endpoints:**

- User repos: `GET /users/{username}/repos?sort=updated&per_page=30`
- Single repo: `GET /repos/{owner}/{repo}`
- Repo README: `GET /repos/{owner}/{repo}/contents/{filename}`

**Error Handling:**

- 404: User/repo not found
- 403: Rate limit exceeded
- Network errors: Fallback to local data

---

## 6. Configuration

### 6.1 Environment Variables

```env
# GitHub username for projects
GITHUB_USERNAME=Denlion09
```

### 6.2 Build Configuration

```javascript
// vite.config.js
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
});
```

### 6.3 External Resources

**CDN Dependencies:**

- Tailwind: `https://cdn.tailwindcss.com`
- FlyonUI: `https://cdn.jsdelivr.net/npm/flyonui@latest/dist/flyonui.min.css`
- Tabler Icons: `https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@3/iconfont/tabler-icons.min.css`
- Google Fonts: `https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap`

---

## 7. Acceptance Criteria

### Visual Checkpoints

- [ ] Navbar displays with logo, theme toggle, and login button
- [ ] Theme toggle switches between dark/light correctly
- [ ] Theme preference persists after page reload
- [ ] Hero section shows avatar, name, title, bio, and social links
- [ ] Projects load from GitHub API or fallback to JSON
- [ ] Project cards display in horizontal scroll container
- [ ] Scroll buttons navigate through projects
- [ ] Footer shows newsletter form and relevant links
- [ ] Responsive layout works on mobile (stacked) and desktop (side-by-side)
- [ ] Main section height is 60vh

### Functionality Checkpoints

- [ ] GitHub stars load for each project
- [ ] All external links open in new tabs
- [ ] Profile data merges correctly from multiple sources
- [ ] Security sanitization prevents XSS attacks
- [ ] Rate limiting prevents API abuse

### Performance Checkpoints

- [ ] Page loads without console errors
- [ ] Images lazy load
- [ ] Smooth scroll animations
- [ ] Theme switch has no flash of wrong theme

---

## 8. Future Improvements

- Add contact form with backend integration
- Implement LinkedIn OAuth for profile data
- Add more project filtering/sorting options
- Implement PWA features
- Add analytics
- Improve accessibility (ARIA labels)
- Add unit tests
