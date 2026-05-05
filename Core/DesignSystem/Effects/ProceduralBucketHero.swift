import SwiftUI
import RealityKit

/// Hero 3D procedural — construye una cubeta con primitivas RealityKit
/// (cylinder + cone + material). Sin assets externos.
///
/// La cubeta queda **fija** en su pose isométrica. NO rota continuo — solo
/// flota muy sutil (idle ±2pt) y reacciona al `tilt` del drag para parallax.
///
/// IMPORTANTE: el material del cuerpo, asa y hoja se actualizan dinámicamente
/// cuando `accent` cambia, sin re-instanciar el RealityView (eso era lo que
/// hacía que las páginas tardaran en cargar). Esto permite UNA sola cubeta
/// compartida en el onboarding.
struct ProceduralBucketHero: View {
    var accent: Color = .brand
    var tilt: CGSize = .zero

    @State private var floatOffset: CGFloat = 0

    var body: some View {
        RealityView { content in
            let bucket = makeBucket(accent: accent)
            content.add(bucket)

            // Iluminación key
            let key = DirectionalLight()
            key.light.intensity = 1100
            key.orientation = simd_quatf(angle: -.pi / 5, axis: SIMD3<Float>(1, 0.2, 0))
            content.add(key)

            // Fill suave
            let fill = DirectionalLight()
            fill.light.intensity = 400
            fill.light.color = .white
            fill.orientation = simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(-0.5, 0.5, 0))
            content.add(fill)
        } update: { content in
            guard let bucket = content.entities.first(where: { $0.name == "bucket-root" }) else { return }

            // Tilt del drag — parallax 3D sutil
            let baseTilt = simd_quatf(angle: -.pi / 8, axis: SIMD3<Float>(1, 0, 0))
            let tiltX = Float(-tilt.height) * 0.003
            let tiltY = Float(tilt.width) * 0.003
            let parallax = simd_quatf(angle: tiltX, axis: SIMD3<Float>(1, 0, 0))
                            * simd_quatf(angle: tiltY, axis: SIMD3<Float>(0, 1, 0))
            bucket.orientation = parallax * baseTilt

            // Re-tint materials con el accent actual (cheap, ~5 entities)
            updateAccentMaterials(in: bucket, accent: accent)
        }
        .background(.clear)
        .offset(y: floatOffset)
        .onAppear {
            withAnimation(.smooth(duration: 4.0).repeatForever(autoreverses: true)) {
                floatOffset = -2
            }
        }
    }
}

// MARK: - Build & Update materials

extension ProceduralBucketHero {
    fileprivate func makeBucket(accent: Color) -> Entity {
        let root = Entity()
        root.name = "bucket-root"

        let body = PhysicallyBasedMaterial.bucketMaterial(tint: accent, darkness: 0)
        let dark = PhysicallyBasedMaterial.bucketMaterial(tint: accent, darkness: 0.55)
        let handleMat = PhysicallyBasedMaterial.bucketMaterial(tint: accent, darkness: 0.30)
        let leafMat = PhysicallyBasedMaterial.bucketMaterial(tint: accent, darkness: -0.15)

        // Cuerpo
        let bodyMesh = MeshResource.generateCylinder(height: 0.32, radius: 0.20)
        let bodyEntity = ModelEntity(mesh: bodyMesh, materials: [body])
        bodyEntity.name = "bucket-body"
        root.addChild(bodyEntity)

        // Borde
        let rimMesh = MeshResource.generateCylinder(height: 0.005, radius: 0.195)
        let rimEntity = ModelEntity(mesh: rimMesh, materials: [dark])
        rimEntity.name = "bucket-rim"
        rimEntity.position = SIMD3<Float>(0, 0.16, 0)
        root.addChild(rimEntity)

        // Asa
        let handleSideMesh = MeshResource.generateCylinder(height: 0.18, radius: 0.012)
        let leftHandle = ModelEntity(mesh: handleSideMesh, materials: [handleMat])
        leftHandle.name = "bucket-handle"
        leftHandle.position = SIMD3<Float>(-0.21, 0.14, 0)
        root.addChild(leftHandle)

        let rightHandle = ModelEntity(mesh: handleSideMesh, materials: [handleMat])
        rightHandle.name = "bucket-handle"
        rightHandle.position = SIMD3<Float>(0.21, 0.14, 0)
        root.addChild(rightHandle)

        let handleTopMesh = MeshResource.generateCylinder(height: 0.42, radius: 0.012)
        let handleTop = ModelEntity(mesh: handleTopMesh, materials: [handleMat])
        handleTop.name = "bucket-handle"
        handleTop.position = SIMD3<Float>(0, 0.24, 0)
        handleTop.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 0, 1))
        root.addChild(handleTop)

        // Hoja
        let leafMesh = MeshResource.generateSphere(radius: 0.05)
        let leaf = ModelEntity(mesh: leafMesh, materials: [leafMat])
        leaf.name = "bucket-leaf"
        leaf.scale = SIMD3<Float>(1.4, 0.4, 1.4)
        leaf.position = SIMD3<Float>(0, 0.30, 0)
        leaf.orientation = simd_quatf(angle: .pi / 6, axis: SIMD3<Float>(0, 0, 1))
        root.addChild(leaf)

        root.orientation = simd_quatf(angle: -.pi / 8, axis: SIMD3<Float>(1, 0, 0))

        return root
    }

    fileprivate func updateAccentMaterials(in bucket: Entity, accent: Color) {
        let bodyMat = PhysicallyBasedMaterial.bucketMaterial(tint: accent, darkness: 0)
        let darkMat = PhysicallyBasedMaterial.bucketMaterial(tint: accent, darkness: 0.55)
        let handleMat = PhysicallyBasedMaterial.bucketMaterial(tint: accent, darkness: 0.30)
        let leafMat = PhysicallyBasedMaterial.bucketMaterial(tint: accent, darkness: -0.15)

        for child in bucket.children {
            guard let model = child as? ModelEntity else { continue }
            switch child.name {
            case "bucket-body":   model.model?.materials = [bodyMat]
            case "bucket-rim":    model.model?.materials = [darkMat]
            case "bucket-handle": model.model?.materials = [handleMat]
            case "bucket-leaf":   model.model?.materials = [leafMat]
            default: break
            }
        }
    }
}

// MARK: - Material helper

private extension PhysicallyBasedMaterial {
    /// `darkness` 0-1 oscurece, valores negativos lo aclaran (para hojas brillantes).
    static func bucketMaterial(tint: Color, darkness: Double = 0) -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        let ui = UIColor(tint)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let factor = max(0, 1.0 - darkness)
        let cgColor = CGColor(
            red: min(1, r * factor),
            green: min(1, g * factor),
            blue: min(1, b * factor),
            alpha: a
        )
        material.baseColor = .init(tint: UIColor(cgColor: cgColor))
        material.roughness = 0.62
        material.metallic = 0.05
        return material
    }
}

#Preview {
    ZStack {
        Color.cream.ignoresSafeArea()
        ProceduralBucketHero(accent: .brand)
            .frame(width: 320, height: 320)
    }
}
