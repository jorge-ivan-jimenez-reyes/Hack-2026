import SwiftUI
import RealityKit

/// Escena 3D del journey onboarding. Construida con primitivas RealityKit
/// (cylinder, box, sphere, cone). Sin assets externos.
struct JourneyScene: View {
    let stationIndex: Int

    var body: some View {
        RealityView { content in
            // Ground
            let ground = JourneyBuilders.makeGround()
            content.add(ground)

            // Path
            let path = JourneyBuilders.makePath()
            content.add(path)

            // 4 stations
            for station in JourneyStation.all {
                let entity = JourneyBuilders.makeStation(for: station)
                entity.position = SIMD3<Float>(station.pathPosition, 0, -0.05)
                content.add(entity)
            }

            // Truck — carga USDZ real de Apple (toy_car) si existe en bundle
            let truck = JourneyBuilders.makeTruckEntity()
            truck.name = "truck-root"
            truck.position = SIMD3<Float>(JourneyStation.all[0].pathPosition, 0.10, 0.30)
            content.add(truck)

            // Lighting
            let key = DirectionalLight()
            key.light.intensity = 1100
            key.orientation = simd_quatf(angle: -.pi / 4, axis: SIMD3<Float>(1, 0.3, 0))
            content.add(key)

            let fill = DirectionalLight()
            fill.light.intensity = 350
            fill.light.color = .white
            fill.orientation = simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(-0.3, 0.5, 0.2))
            content.add(fill)

            // Camera
            let camera = PerspectiveCamera()
            camera.name = "camera"
            camera.camera.fieldOfViewInDegrees = 35
            let camPos = JourneyBuilders.cameraPosition(for: 0)
            let camTarget = JourneyBuilders.cameraTarget(for: 0)
            camera.position = camPos
            camera.look(at: camTarget, from: camPos, relativeTo: nil as Entity?)
            content.add(camera)
        } update: { content in
            // Move truck
            if let truck = content.entities.first(where: { $0.name == "truck-root" }) {
                let target = SIMD3<Float>(JourneyBuilders.stationX(for: stationIndex), 0.10, 0.30)
                let truckTransform = Transform(
                    scale: truck.scale,
                    rotation: truck.transform.rotation,
                    translation: target
                )
                truck.move(
                    to: truckTransform,
                    relativeTo: truck.parent,
                    duration: 1.4,
                    timingFunction: AnimationTimingFunction.easeInOut
                )

                // Wheel rotation
                for wheel in truck.children where wheel.name == "wheel" {
                    let spin = simd_quatf(angle: -2 * .pi * 3, axis: SIMD3<Float>(1, 0, 0))
                    let t = Transform(
                        scale: wheel.scale,
                        rotation: spin * wheel.transform.rotation,
                        translation: wheel.position
                    )
                    wheel.move(to: t, relativeTo: wheel.parent, duration: 1.4, timingFunction: AnimationTimingFunction.easeInOut)
                }
            }

            // Move camera
            if let camera = content.entities.first(where: { $0.name == "camera" }) {
                let newPos = JourneyBuilders.cameraPosition(for: stationIndex)
                let newTarget = JourneyBuilders.cameraTarget(for: stationIndex)
                let camTransform = Transform(
                    scale: camera.scale,
                    rotation: camera.transform.rotation,
                    translation: newPos
                )
                camera.move(
                    to: camTransform,
                    relativeTo: camera.parent,
                    duration: 1.4,
                    timingFunction: AnimationTimingFunction.easeInOut
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    camera.look(at: newTarget, from: newPos, relativeTo: nil as Entity?)
                }
            }
        }
        .background(.clear)
    }
}

// MARK: - Builders

/// Helpers procedurales para construir el mundo 3D del journey.
@MainActor
enum JourneyBuilders {

    static func stationX(for i: Int) -> Float {
        let stations = JourneyStation.all
        let safe = max(0, min(stations.count - 1, i))
        return stations[safe].pathPosition
    }

    static func cameraPosition(for i: Int) -> SIMD3<Float> {
        SIMD3<Float>(stationX(for: i) + 0.4, 1.6, 2.4)
    }

    static func cameraTarget(for i: Int) -> SIMD3<Float> {
        SIMD3<Float>(stationX(for: i), 0.05, 0)
    }

    // MARK: - Ground & Path

    static func makeGround() -> Entity {
        let mesh = MeshResource.generatePlane(width: 12, depth: 6)
        var mat = PhysicallyBasedMaterial()
        mat.baseColor = .init(tint: UIColor(Color.cream))
        mat.roughness = 0.95
        return ModelEntity(mesh: mesh, materials: [mat])
    }

    static func makePath() -> Entity {
        let root = Entity()

        let pathMesh = MeshResource.generateBox(size: SIMD3<Float>(8.5, 0.02, 0.6))
        var pathMat = PhysicallyBasedMaterial()
        pathMat.baseColor = .init(tint: UIColor(red: 0.78, green: 0.71, blue: 0.55, alpha: 1.0))
        pathMat.roughness = 0.9
        let path = ModelEntity(mesh: pathMesh, materials: [pathMat])
        path.position = SIMD3<Float>(0, 0.011, 0.3)
        root.addChild(path)

        // Grass tufts
        for i in 0..<10 {
            let tx = -4.0 + Float(i) * 0.9
            let tz: Float = i % 2 == 0 ? -0.3 : 0.95
            let tuft = makeGrassTuft()
            tuft.position = SIMD3<Float>(tx, 0.025, tz)
            root.addChild(tuft)
        }

        return root
    }

    static func makeGrassTuft() -> Entity {
        let mesh = MeshResource.generateSphere(radius: 0.06)
        var mat = PhysicallyBasedMaterial()
        mat.baseColor = .init(tint: UIColor(Color.moss))
        mat.roughness = 0.85
        let entity = ModelEntity(mesh: mesh, materials: [mat])
        entity.scale = SIMD3<Float>(1.2, 0.5, 1.2)
        return entity
    }

    // MARK: - Truck

    static func makeTruckEntity() -> Entity {
        makeTruckProcedural()
    }

    /// Construye un camión de basura procedural — cabina + cargo bin grande
    /// + fork lift frontal + 4 ruedas + logo recycle + faros.
    static func makeTruckProcedural() -> Entity {
        let root = Entity()

        let bodyMat = pbr(color: .brand, roughness: 0.45, metallic: 0.20)
        let darkBody = pbr(color: .brand, roughness: 0.5, metallic: 0.20, darkness: 0.35)
        let bumperMat = pbr(color: .inkCharcoal, roughness: 0.4, metallic: 0.5)
        let cargoMat = pbr(color: .moss, roughness: 0.55, metallic: 0.15)
        let cargoLid = pbr(color: .moss, roughness: 0.55, metallic: 0.15, darkness: 0.25)
        let trashMat = pbr(color: .limeSpark, roughness: 0.6)
        let trashDark = pbr(color: .clay, roughness: 0.7)
        let wheelMat = pbr(color: .inkCharcoal, roughness: 0.4, metallic: 0.4)
        let rimMat = pbr(color: .cream, roughness: 0.3, metallic: 0.7)
        let windowMat = pbr(color: .forestDeep, roughness: 0.2, metallic: 0.8)
        let lightMat = pbr(color: .limeSpark, roughness: 0.1, metallic: 0.2)

        // ========== CHASIS BASE ==========
        let chassis = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.70, 0.04, 0.32)),
            materials: [darkBody]
        )
        chassis.position = SIMD3<Float>(0.05, 0.08, 0)
        root.addChild(chassis)

        // ========== CABINA (DRIVER) ==========
        // Cabina principal
        let cab = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.18, 0.18, 0.30)),
            materials: [bodyMat]
        )
        cab.position = SIMD3<Float>(-0.22, 0.20, 0)
        root.addChild(cab)

        // Techo de cabina (más oscuro)
        let cabRoof = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.18, 0.025, 0.30)),
            materials: [darkBody]
        )
        cabRoof.position = SIMD3<Float>(-0.22, 0.30, 0)
        root.addChild(cabRoof)

        // Parabrisas (front window)
        let frontWindow = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.005, 0.10, 0.25)),
            materials: [windowMat]
        )
        frontWindow.position = SIMD3<Float>(-0.314, 0.22, 0)
        root.addChild(frontWindow)

        // Ventanas laterales
        for zSign: Float in [-1, 1] {
            let sideWin = ModelEntity(
                mesh: MeshResource.generateBox(size: SIMD3<Float>(0.16, 0.08, 0.005)),
                materials: [windowMat]
            )
            sideWin.position = SIMD3<Float>(-0.22, 0.22, zSign * 0.153)
            root.addChild(sideWin)
        }

        // Faros frontales
        for zSign: Float in [-1, 1] {
            let light = ModelEntity(
                mesh: MeshResource.generateSphere(radius: 0.022),
                materials: [lightMat]
            )
            light.scale = SIMD3<Float>(0.5, 1, 1)
            light.position = SIMD3<Float>(-0.314, 0.13, zSign * 0.10)
            root.addChild(light)
        }

        // Bumper (parachoques)
        let bumper = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.025, 0.04, 0.32)),
            materials: [bumperMat]
        )
        bumper.position = SIMD3<Float>(-0.318, 0.08, 0)
        root.addChild(bumper)

        // ========== CARGO BIN GRANDE (la "caja" de basura) ==========
        // Caja principal bien grande y verde moss (clásico camión de basura)
        let cargoBox = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.42, 0.30, 0.32)),
            materials: [cargoMat]
        )
        cargoBox.position = SIMD3<Float>(0.18, 0.25, 0)
        root.addChild(cargoBox)

        // Top lid (tapa superior un poco más oscura)
        let lid = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.40, 0.025, 0.30)),
            materials: [cargoLid]
        )
        lid.position = SIMD3<Float>(0.18, 0.41, 0)
        root.addChild(lid)

        // Trash overflow asomándose (4 esferas verdes + 2 marrones tipo orgánico)
        let trashOffsets: [(Float, Float, Float)] = [
            (-0.10, 0.42, -0.08), (0.0, 0.43, -0.06), (0.08, 0.44, 0.04),
            (-0.04, 0.42, 0.08), (0.04, 0.45, -0.02), (-0.08, 0.44, 0.06)
        ]
        for (i, (dx, y, dz)) in trashOffsets.enumerated() {
            let isBrown = (i == 1 || i == 4)  // 2 brown, 4 green
            let trash = ModelEntity(
                mesh: MeshResource.generateSphere(radius: 0.040),
                materials: [isBrown ? trashDark : trashMat]
            )
            trash.scale = SIMD3<Float>(1.3, 0.6, 1.3)
            trash.position = SIMD3<Float>(0.18 + dx, y, dz)
            root.addChild(trash)
        }

        // Logo de reciclaje en el costado (placa cream con símbolo brand)
        for zSign: Float in [-1, 1] {
            let placa = ModelEntity(
                mesh: MeshResource.generateBox(size: SIMD3<Float>(0.10, 0.10, 0.005)),
                materials: [pbr(color: .cream, roughness: 0.6)]
            )
            placa.position = SIMD3<Float>(0.18, 0.25, zSign * 0.163)
            root.addChild(placa)

            let logo = ModelEntity(
                mesh: MeshResource.generateBox(size: SIMD3<Float>(0.08, 0.06, 0.008)),
                materials: [bodyMat]
            )
            logo.position = SIMD3<Float>(0.18, 0.25, zSign * 0.166)
            root.addChild(logo)
        }

        // Lift arms — los brazos hidráulicos atrás del camión
        for zSign: Float in [-1, 1] {
            let arm = ModelEntity(
                mesh: MeshResource.generateBox(size: SIMD3<Float>(0.12, 0.025, 0.025)),
                materials: [bumperMat]
            )
            arm.position = SIMD3<Float>(0.43, 0.18, zSign * 0.10)
            root.addChild(arm)
        }

        // ========== 6 WHEELS (más realista para camión grande) ==========
        let wheelMesh = MeshResource.generateCylinder(height: 0.05, radius: 0.075)
        let wheelOffsets: [(Float, Float)] = [
            (-0.22, -0.16), (-0.22, 0.16),  // Front
            (0.05, -0.16),  (0.05, 0.16),    // Mid
            (0.30, -0.16),  (0.30, 0.16)     // Rear
        ]
        for (dx, dz) in wheelOffsets {
            let wheel = ModelEntity(mesh: wheelMesh, materials: [wheelMat])
            wheel.name = "wheel"
            wheel.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0))
            wheel.position = SIMD3<Float>(dx, 0.05, dz)
            root.addChild(wheel)

            // Rim (cubo)
            let rim = ModelEntity(
                mesh: MeshResource.generateCylinder(height: 0.052, radius: 0.030),
                materials: [rimMat]
            )
            rim.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0))
            rim.position = SIMD3<Float>(dx, 0.05, dz)
            root.addChild(rim)
        }

        // Flip 180° en Y — la cabina ahora mira en dirección de movimiento (+X)
        root.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))

        return root
    }

    // MARK: - Stations

    static func makeStation(for station: JourneyStation) -> Entity {
        switch station.id {
        case 0: return makeStationCubeta(accent: station.accent)
        case 1: return makeStationHouse(accent: station.accent)
        case 2: return makeStationCompostPile(accent: station.accent)
        case 3: return makeStationCommunity(accent: station.accent)
        default: return Entity()
        }
    }

    static func makeStationCubeta(accent: Color) -> Entity {
        let root = Entity()

        let bodyMat = pbr(color: accent, roughness: 0.6)
        let darkMat = pbr(color: accent, roughness: 0.7, darkness: 0.4)
        let leafMat = pbr(color: .limeSpark, roughness: 0.5)

        let body = ModelEntity(
            mesh: MeshResource.generateCylinder(height: 0.18, radius: 0.12),
            materials: [bodyMat]
        )
        body.position = SIMD3<Float>(0, 0.10, 0)
        root.addChild(body)

        let rim = ModelEntity(
            mesh: MeshResource.generateCylinder(height: 0.005, radius: 0.115),
            materials: [darkMat]
        )
        rim.position = SIMD3<Float>(0, 0.19, 0)
        root.addChild(rim)

        let leaf = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.04),
            materials: [leafMat]
        )
        leaf.scale = SIMD3<Float>(1.3, 0.4, 1.3)
        leaf.position = SIMD3<Float>(0, 0.24, 0)
        root.addChild(leaf)

        return root
    }

    static func makeStationHouse(accent: Color) -> Entity {
        let root = Entity()

        let bodyMat = pbr(color: .cream, roughness: 0.7)
        let roofMat = pbr(color: accent, roughness: 0.5)
        let doorMat = pbr(color: accent, roughness: 0.6, darkness: 0.3)

        let body = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.22, 0.20, 0.20)),
            materials: [bodyMat]
        )
        body.position = SIMD3<Float>(0, 0.11, 0)
        root.addChild(body)

        let roof = ModelEntity(
            mesh: MeshResource.generateCone(height: 0.14, radius: 0.18),
            materials: [roofMat]
        )
        roof.position = SIMD3<Float>(0, 0.28, 0)
        root.addChild(roof)

        let door = ModelEntity(
            mesh: MeshResource.generateBox(size: SIMD3<Float>(0.005, 0.10, 0.06)),
            materials: [doorMat]
        )
        door.position = SIMD3<Float>(-0.111, 0.06, 0)
        root.addChild(door)

        return root
    }

    static func makeStationCompostPile(accent: Color) -> Entity {
        let root = Entity()

        let leafMat = pbr(color: .limeSpark, roughness: 0.55)
        let darkMat = pbr(color: accent, roughness: 0.7, darkness: 0.5)

        let base = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.13),
            materials: [darkMat]
        )
        base.scale = SIMD3<Float>(1.4, 0.5, 1.4)
        base.position = SIMD3<Float>(0, 0.06, 0)
        root.addChild(base)

        for i in 0..<5 {
            let angle = Double(i) * 2 * .pi / 5
            let leaf = ModelEntity(
                mesh: MeshResource.generateSphere(radius: 0.045),
                materials: [leafMat]
            )
            leaf.scale = SIMD3<Float>(1.1, 0.45, 1.1)
            leaf.position = SIMD3<Float>(
                Float(cos(angle)) * 0.07,
                0.13,
                Float(sin(angle)) * 0.07
            )
            root.addChild(leaf)
        }

        let topLeaf = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.05),
            materials: [leafMat]
        )
        topLeaf.scale = SIMD3<Float>(1.2, 0.5, 1.2)
        topLeaf.position = SIMD3<Float>(0, 0.18, 0)
        root.addChild(topLeaf)

        return root
    }

    static func makeStationCommunity(accent: Color) -> Entity {
        let root = Entity()

        let mat = pbr(color: accent, roughness: 0.6)
        let darkMat = pbr(color: accent, roughness: 0.7, darkness: 0.4)

        for i in 0..<6 {
            let angle = Double(i) * 2 * .pi / 6
            let mini = Entity()

            let body = ModelEntity(
                mesh: MeshResource.generateCylinder(height: 0.10, radius: 0.06),
                materials: [mat]
            )
            body.position = SIMD3<Float>(0, 0.05, 0)
            mini.addChild(body)

            let rim = ModelEntity(
                mesh: MeshResource.generateCylinder(height: 0.003, radius: 0.058),
                materials: [darkMat]
            )
            rim.position = SIMD3<Float>(0, 0.10, 0)
            mini.addChild(rim)

            mini.position = SIMD3<Float>(
                Float(cos(angle)) * 0.16,
                0,
                Float(sin(angle)) * 0.16
            )
            root.addChild(mini)
        }

        return root
    }

    // MARK: - Material helper

    static func pbr(
        color: Color,
        roughness: Float = 0.6,
        metallic: Float = 0.05,
        darkness: Double = 0
    ) -> PhysicallyBasedMaterial {
        var mat = PhysicallyBasedMaterial()
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let factor = max(0, 1.0 - darkness)
        let cgColor = CGColor(
            red: min(1, r * factor),
            green: min(1, g * factor),
            blue: min(1, b * factor),
            alpha: a
        )
        mat.baseColor = .init(tint: UIColor(cgColor: cgColor))
        mat.roughness = .init(floatLiteral: roughness)
        mat.metallic = .init(floatLiteral: metallic)
        return mat
    }
}
