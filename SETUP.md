# SETUP — Bootstrap del proyecto Xcode

Pasos para que el scaffolding de Swift compile y corra. Hacer esto antes del día del hackathon — idealmente esta misma semana.

## 1. Requisitos

- macOS 26.x (Tahoe) o superior
- **Xcode 26** instalado (SDK 26.2 o más nuevo)
- Apple ID con cuenta de developer (gratuita sirve para correr en simulador y dispositivo)

## 2. Crear el proyecto Xcode

1. Abrir Xcode → **File → New → Project → iOS App**
2. Configuración:
   - **Product Name:** `HackNacional2026`
   - **Organization Identifier:** `mx.up.ioslab`
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** SwiftData
   - **Include Tests:** ✅ (los borramos si sobra tiempo)
3. Guardar el `.xcodeproj` en la **raíz** de este repo (junto a este `SETUP.md`).
4. Borrar los archivos default que crea Xcode:
   - `HackNacional2026App.swift` (ya tenemos uno mejor en `App/`)
   - `ContentView.swift`
   - `Assets.xcassets` (ya tenemos uno mejor en `Resources/`)

## 3. Importar el código del repo

1. En Xcode → click derecho en el proyecto → **Add Files to "HackNacional2026"…**
2. Seleccionar las carpetas: `App/`, `Core/`, `Features/`, `Resources/`
3. Marcar:
   - **Copy items if needed:** ❌ NO (ya están en el repo)
   - **Create groups:** ✅
   - **Add to target:** HackNacional2026
4. Verificar que `Resources/Assets.xcassets` aparece como Asset Catalog en Xcode.

## 4. Configurar Info.plist (Project → Target → Info)

Agregar estas keys con su descripción:

| Key | Valor |
|---|---|
| `NSCameraUsageDescription` | Para escanear residuos y clasificarlos. |
| `NSPhotoLibraryAddUsageDescription` | Para guardar capturas de tus escaneos. |
| `NSSpeechRecognitionUsageDescription` | Para input por voz. (cuando se agregue) |

## 5. Deployment Target

Project → Target → **General** → Minimum Deployments → **iOS 26.0**

> Foundation Models requiere 26+. SwiftData ya está disponible. SDK 26 es obligatorio para subir a App Store desde abril 2026.

## 6. Capabilities

Project → Target → **Signing & Capabilities**:
- Asegurarse de que **Automatically manage signing** está activo.
- Seleccionar el Team del Apple ID.
- No se necesita ninguna capability extra para el primer drop.

## 7. Validar build

`Cmd+B`. Debe compilar sin errores.

Posibles fricciones:
- Si quejas de `FoundationModels`, verificar que el SDK target es iOS 26+.
- Si quejas de `.glassEffect`, verificar que estás en Xcode 26 (la API es nueva).
- Si quejas de `Tab(...) { ... }` (TabView nueva API), ídem — Xcode 26.

## 8. Correr en simulador

- Escoger simulador **iPhone 16 Pro** o superior con iOS 26.
- `Cmd+R`. La app debe arrancar y mostrar Onboarding.
- Tap "Empezar" → llega al Scanner.
- ⚠️ La cámara **no funciona en simulador**. Para probarla, usa dispositivo físico.

## 9. Correr en dispositivo físico

- Conectar iPhone con iOS 26.
- Seleccionar el dispositivo en el dropdown de Xcode.
- `Cmd+R`. Aceptar el certificado de developer en Ajustes → General → VPN y administración de dispositivos.

---

## Día del hackathon — qué cambia cuando se anuncie el reto

### Si el reto pide clasificación de imágenes
1. Bajar/entrenar modelo `.mlmodel` (Create ML, dataset público como TrashNet o TACO).
2. Drag a `Resources/MLModels/` y add to target.
3. En `Core/AI/VisionWasteClassifier.swift` reemplazar `loadModel()`:
   ```swift
   try VNCoreMLModel(for: WasteClassifierV1(configuration: .init()).model)
   ```
4. Ajustar `WasteCategory.init?(rawIdentifier:)` con los labels reales del modelo.
5. En `ScannerCoordinator.init`, cambiar `MockWasteClassifier()` → `VisionWasteClassifier()`.

### Si el reto necesita coach IA real
1. Verificar Apple Intelligence en el iPhone de demo (Ajustes → Apple Intelligence → activar).
2. Ajustar `systemInstructions` en `Core/AI/FoundationModelsCoach.swift` al contexto del reto.
3. En `ScannerCoordinator.init` y `CoachState.init`, cambiar `MockLanguageCoach()` → `FoundationModelsCoach()`.

### Si el reto pide categorías distintas (ej. solo PET, vidrio, metal)
1. Ajustar `WasteCategory` enum en `Core/Models/`.
2. Si los colores cambian, actualizar `Resources/Assets.xcassets/Colors/`.

### Si el reto pide otro feature (ej. logística, trazabilidad)
1. Crear nueva carpeta en `Features/<NuevoFeature>/`.
2. Reusar Camera, Storage, AI, DesignSystem.
3. Agregar `Tab` en `App/RootView.swift`.

### Antes del pitch
- Llenar Keynote del comité con datos del equipo (`docs/team.md` template).
- Verificar Light + Dark mode en cada vista.
- Probar VoiceOver en flujo completo: Onboarding → Scanner → Result → Save → History.
- Probar Dynamic Type en xxxLarge.
- Cronometrar pitch a 10 minutos.
