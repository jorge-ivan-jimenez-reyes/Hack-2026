import SwiftUI
import RealityKit

/// Renderiza un modelo 3D `.usdz` con `RealityView` (nativo iOS 18+).
/// Auto-escala al tamaño del view, juega cualquier animación bakeada en el USDZ,
/// y si no hay, le aplica una rotación continua sutil.
///
/// **Uso:** mete tu archivo `.usdz` en `Resources/USDZ/` y pasa el nombre
/// (sin extensión) al inicializar:
/// ```swift
/// USDZHero(modelName: "compost-bucket")
/// ```
///
/// Si el modelo no existe en el bundle, el view queda vacío — usar
/// `USDZHero.exists(_:)` para verificar antes y caer a otro hero.
struct USDZHero: View {
    let modelName: String
    var rotationDuration: TimeInterval = 12

    var body: some View {
        RealityView { content in
            guard let entity = try? await Entity(named: modelName, in: nil) else {
                return
            }

            // Centrar y escalar para que quepa en un ~320pt frame
            let bounds = entity.visualBounds(relativeTo: nil)
            let maxExtent = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
            if maxExtent > 0 {
                let scale = 0.55 / maxExtent
                entity.scale = SIMD3<Float>(repeating: scale)
                entity.position = -bounds.center * scale
            }

            content.add(entity)

            // Jugar animaciones bakeadas (si las tiene)
            let bakedAnimations = entity.availableAnimations
            if !bakedAnimations.isEmpty {
                for anim in bakedAnimations {
                    entity.playAnimation(anim.repeat())
                }
            } else {
                // Si no hay animación, rotar suave en eje Y
                applyContinuousYRotation(to: entity)
            }
        }
        .background(.clear)
    }

    /// Verifica si un USDZ existe en el bundle. Útil para decidir entre USDZHero
    /// y HeroSymbol fallback antes de instanciar.
    static func exists(_ modelName: String) -> Bool {
        Bundle.main.url(forResource: modelName, withExtension: "usdz") != nil
    }

    private func applyContinuousYRotation(to entity: Entity) {
        let rotation = simd_quatf(angle: 2 * .pi, axis: SIMD3<Float>(0, 1, 0))
        let transform = Transform(
            scale: entity.scale,
            rotation: rotation * entity.transform.rotation,
            translation: entity.position
        )
        entity.move(
            to: transform,
            relativeTo: entity.parent,
            duration: rotationDuration,
            timingFunction: .linear
        )
        // Loop: re-aplicar al terminar (RealityKit no tiene `.repeat()` para move)
        DispatchQueue.main.asyncAfter(deadline: .now() + rotationDuration) {
            self.applyContinuousYRotation(to: entity)
        }
    }
}
