# Lottie Animations

JSONs de [LottieFiles](https://lottiefiles.com) se cargan acá. Los usa `LottiePlayer(name:fallbackSymbol:)` desde `Core/DesignSystem/Effects/LottiePlayer.swift`.

> **Importante:** la app **NUNCA se rompe** por falta de un JSON. `LottiePlayer` automáticamente vuelve al SF Symbol con animación `.pulse` como fallback. Puedes compilar y correr sin ningún archivo aquí.

## Cómo agregar uno

1. Ir a [lottiefiles.com](https://lottiefiles.com) y buscar la animación
2. Crear cuenta gratis (o login)
3. Click en la animación → **"Lottie JSON"** → descargar
4. Guardar el archivo aquí con el nombre exacto de la tabla de abajo
5. Correr `xcodegen generate` para regenerar el `.xcodeproj` (XcodeGen incluye automáticamente todo `.json` de esta carpeta)
6. Rebuild → ya jala automáticamente

## JSONs esperados — Guía de Reciclaje

| Archivo | Dónde se usa | Qué buscar en LottieFiles |
|---|---|---|
| `guide-organic.json` | Hero de Residuos Orgánicos | "compost", "organic waste", "leaves", "leaf" |
| `guide-inorganic.json` | Hero de Residuos Inorgánicos | "recycling", "recycle loop", "plastic bottle" |
| `guide-sanitary.json` | Hero de Residuos Sanitarios | "medical waste", "sanitary", "clean" |
| `quiz-correct.json` | Feedback correcto en el quiz | "checkmark", "success", "correct", "check" |
| `quiz-wrong.json` | Feedback incorrecto en el quiz | "wrong", "error", "x mark", "incorrect" |
| `quiz-trophy.json` | Pantalla de resultados | "trophy", "award", "winner", "celebration" |
| `recycle-loop.json` | Ícono en el header de la guía | "recycling symbol", "recycle loop" |

## JSONs esperados — Otros

| Archivo | Dónde se usa | Qué buscar |
|---|---|---|
| `onboarding-leaf.json` | Onboarding hero icon | "leaf", "eco", "plant" |
| `sparkle-ai.json` | Coach greeter | "sparkle", "ai", "stars" |

## Licencias

Verifica que la animación sea compatible con uso en hackathon: **CC0, MIT, "free for any use"**, o licencia de LottieFiles "Free". Si pide atribución, agrégala en `docs/credits.md`. Evita las que digan "Premium".

## Links útiles

- [Eco-friendly animations](https://lottiefiles.com/free-animations/eco-friendly)
- [Sustainability animations](https://lottiefiles.com/free-animations/sustainability)
- [Recycling animations](https://lottiefiles.com/free-animations/recycling)
- [Success / checkmark](https://lottiefiles.com/free-animations/check)
- [Trophy / award](https://lottiefiles.com/free-animations/award)
