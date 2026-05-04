# HackNacional 2026 — Swift Changemakers

App iOS para el **Swift Changemakers Hackathon 2026**.
Categoría: **Human-Centered AI**. Eje: **Residuos**.
Universidad Panamericana · iOS Lab.

## Equipo
- Jorge — Tech Lead / Dev
- Esteban Mayoral — Dev
- Montserrat Navarro — Diseño
- Iñaki — Lab Manager

## Reto específico
_Pendiente — se anuncia al inicio del evento._

## Stack
- Swift · SwiftUI · **Xcode 26**
- **iOS 26+** (Foundation Models, Liquid Glass, SwiftData)
- Core ML · Vision · Speech · AVFoundation
- Apple Foundation Models (LLM on-device)

## Arquitectura
- Patrón **MV con `@Observable`** (no MVVM clásico)
- `ScannerCoordinator` es el único caso de "VM" porque orquesta 3 servicios
- Servicios de IA tras `protocol`s con **mock por default** → previews y demos sin modelo real
- Design system propio (Liquid Glass + tokens semánticos) en `Core/DesignSystem/`

## Estructura del repo
```
App/                       @main + RootView (TabView)
Core/
  ├── Models/              WasteCategory, Classification (dominio)
  ├── AI/                  WasteClassifier + LanguageCoach (protocols + mocks + reales)
  ├── Camera/              CameraService + CameraPreview (AVFoundation)
  ├── Storage/             ScanRecord (@Model SwiftData)
  ├── DesignSystem/        Theme, Typography, GlassStyle + Components/
  └── Accessibility/       modificadores reutilizables
Features/
  ├── Scanner/             cámara → IA → resultado (corazón)
  ├── History/             scans guardados (@Query directo)
  ├── Coach/               chat con LLM on-device
  └── Onboarding/          comunica privacidad + permisos
Resources/Assets.xcassets/ paleta semántica (18 colores, light + dark)
docs/                      Keynote, pitch script
```

## Documentos clave
- [`SETUP.md`](./SETUP.md) — bootstrap del Xcode project (hacer primero)
- [`SYSTEM_PROMPT.md`](./SYSTEM_PROMPT.md) — contexto para asistentes de IA
- [`RUBRIC.md`](./RUBRIC.md) — rúbrica desglosada con checklist
- [`IDEAS.md`](./IDEAS.md) — brainstorm de retos posibles

## Licencia
Durante el evento: **CC0 1.0 Universal**. Al cierre, los derechos vuelven al equipo.
