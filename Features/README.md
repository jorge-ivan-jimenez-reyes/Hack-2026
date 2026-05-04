# Features

Una carpeta por feature. Cada una con:
```
FeatureName/
├── Views/         vistas SwiftUI
├── ViewModels/    @Observable
└── Models/        structs/enums propios del feature
```

Reglas:
- Un feature NO importa de otro feature. Si necesitan compartir, sube a `Core/`.
- Cada View tiene `#Preview`.
- Strings de UI en español.
