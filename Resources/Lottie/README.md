# Lottie Animations

JSONs de [LottieFiles](https://lottiefiles.com) se cargan acá. Los usa `LottiePlayer(name:fallbackSymbol:)` desde `Core/DesignSystem/Effects/LottiePlayer.swift`.

> **Importante:** la app **NUNCA se rompe** por falta de un JSON. `LottiePlayer` automáticamente vuelve al SF Symbol con animación `.pulse` como fallback.

## Cómo agregar uno

1. Ir a [LottieFiles eco-friendly free](https://lottiefiles.com/free-animations/eco-friendly) o [sustainability free](https://lottiefiles.com/free-animations/sustainability)
2. Crear cuenta gratis (o login)
3. Click en la animación deseada → **"Lottie JSON"** → descargar
4. Guardar el archivo aquí con nombre slug, ej. `onboarding-leaf.json`
5. Correr `xcodegen generate` para regenerar el `.xcodeproj` (XcodeGen incluye automáticamente todo `.json` de esta carpeta)
6. Rebuild → ya jala con `LottiePlayer(name: "onboarding-leaf", fallbackSymbol: "leaf.circle.fill")`

## JSONs esperados (cuando los bajen)

| Nombre del archivo | Dónde se usa | Tema sugerido |
|---|---|---|
| `onboarding-leaf.json` | Onboarding hero icon | Hoja verde animada |
| `recycle-loop.json` | History empty state | Símbolo de reciclaje girando |
| `sparkle-ai.json` | Coach greeter | Estrellitas / IA |

## Licencias

Verifica que la animación sea compatible con uso en hackathon: **CC0, MIT, "free for any use"**, o licencia de LottieFiles "Free". Si pide atribución, agrégala en `docs/credits.md`.

## Animaciones gratis recomendadas (verifica licencia antes)

- [Eco Living](https://lottiefiles.com/13893-eco-living)
- [Eco Friendly / Green Energy](https://lottiefiles.com/47813-eco-friendly-environmentally-friendly-green-energy-renewable-energy)
- [Free Eco-Friendly Pack](https://lottiefiles.com/free-animations/eco-friendly)
- [Free Sustainability Pack](https://lottiefiles.com/free-animations/sustainability)
