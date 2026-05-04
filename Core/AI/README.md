# Core/AI

Wrappers limpios sobre Foundation Models, Core ML, Vision.
Las Views NUNCA importan estos frameworks directamente — siempre vía estos servicios.

Estructura sugerida:
```
WasteClassifier.swift       Vision + Core ML → categoría + confianza
LanguageCoach.swift         Foundation Models → explicaciones / tips
AIAvailability.swift        chequea Apple Intelligence / fallbacks
```

Cada servicio expone una interfaz `protocol` para poder mockear en previews/tests.
