import Foundation
import SwiftUI

/// Almacenamiento persistente del progreso del recolector. Único punto de
/// verdad para `bucketProgress`, `bucketsCompleted` y `totalKgDiverted`.
/// Tanto el Home (lectura) como el Scanner (escritura tras guardar) lo usan.
///
/// Usa `@AppStorage` por simplicidad — para producción migrar a SwiftData.
enum RecolectorProgress {
    /// Cada scan que se guarda suma esta fracción al progreso de la cubeta.
    /// Asumimos ~15 items por cubeta llena.
    static let scanFraction: Double = 1.0 / 15.0

    /// Estimación de kg promedio por item escaneado (orgánico chico).
    static let kgPerScan: Double = 0.3

    /// Cubetas necesarias para recibir abono — el ciclo 15:1.
    static let bucketsForAbono: Int = 15

    /// Llamado desde `ResultView.save()` cuando un escaneo se confirma.
    /// Avanza el progreso y, si la cubeta se llena, suma al contador
    /// y reinicia. Cuando llegamos a 15 cubetas, el Home muestra `.abonoReady`.
    static func recordScan(category: WasteCategory) {
        let defaults = UserDefaults.standard

        var progress = defaults.double(forKey: Keys.bucketProgress)
        var completed = defaults.integer(forKey: Keys.bucketsCompleted)
        var totalKg = defaults.double(forKey: Keys.totalKg)
        let streak = max(1, defaults.integer(forKey: Keys.streakDays))

        // Solo orgánico llena la cubeta de composta. Lo demás suma a totalKg
        // pero no a la cubeta — separación correcta importa.
        if category == .organic {
            progress += scanFraction
            totalKg += kgPerScan

            if progress >= 1.0 {
                progress = 0
                if completed < bucketsForAbono {
                    completed += 1
                }
            }
        }

        defaults.set(progress, forKey: Keys.bucketProgress)
        defaults.set(completed, forKey: Keys.bucketsCompleted)
        defaults.set(totalKg, forKey: Keys.totalKg)
        defaults.set(streak, forKey: Keys.streakDays)
    }

    /// Resetea el ciclo cuando el usuario recibe abono (cierra el loop 15:1).
    /// Mantiene `totalKgDiverted` (es histórico) y la racha.
    static func resetCycle() {
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: Keys.bucketProgress)
        defaults.set(0, forKey: Keys.bucketsCompleted)
    }

    /// Si nunca se ha sembrado, mete valores iniciales razonables para que
    /// las cards de impacto no se vean vacías. Se ejecuta una sola vez
    /// (gated por `didSeedDefaults`).
    static func seedIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: Keys.didSeed) else { return }
        // Solo siembra si TODO está en 0 — respeta progreso real del usuario.
        let progress = defaults.double(forKey: Keys.bucketProgress)
        let completed = defaults.integer(forKey: Keys.bucketsCompleted)
        let totalKg = defaults.double(forKey: Keys.totalKg)
        guard progress == 0, completed == 0, totalKg == 0 else {
            defaults.set(true, forKey: Keys.didSeed)
            return
        }
        // Valores creíbles de "ya llevas un par de semanas"
        defaults.set(0.40, forKey: Keys.bucketProgress)
        defaults.set(3, forKey: Keys.bucketsCompleted)
        defaults.set(18.6, forKey: Keys.totalKg)
        defaults.set(11, forKey: Keys.streakDays)
        defaults.set(true, forKey: Keys.didSeed)
    }

    /// Pone el state en avanzado para demos — útil mientras hacemos pitch.
    static func loadDemoState() {
        let defaults = UserDefaults.standard
        defaults.set(0.47, forKey: Keys.bucketProgress)
        defaults.set(7, forKey: Keys.bucketsCompleted)
        defaults.set(42.3, forKey: Keys.totalKg)
        defaults.set(12, forKey: Keys.streakDays)
    }

    /// Para testing: pone el state al borde del ciclo (14/15) — el siguiente scan
    /// llena la cubeta y dispara abonoReady.
    static func loadAlmostAbonoState() {
        let defaults = UserDefaults.standard
        defaults.set(0.93, forKey: Keys.bucketProgress)
        defaults.set(14, forKey: Keys.bucketsCompleted)
        defaults.set(58.0, forKey: Keys.totalKg)
        defaults.set(28, forKey: Keys.streakDays)
    }

    enum Keys {
        static let bucketProgress = "recolector.bucketProgress"
        static let bucketsCompleted = "recolector.bucketsCompleted"
        static let totalKg = "recolector.totalKgDiverted"
        static let streakDays = "recolector.streakDays"
        static let didSeed = "recolector.didSeedDefaults"
    }
}
